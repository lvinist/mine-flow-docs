# Handoff Report: STEP-55.6 Residual Defects (R1 & R2 Investigation)

**Author:** Explorer 1 (`explorer_m1_1`)  
**Target Milestone:** STEP-55.6 Residual Defects Resolution  
**Focus:** R1 (DailyLogFormSheet double-pop / navigation to `/teams`) & R2 (foreman list view log visibility in `daily_log_journey_test.dart`)

---

## 1. Observation

### R1 Observations: Post-Submit Navigation & Stack Pop Race
1. **Route Hierarchy in `lib/app/router.dart:602-745`**:
   - `AppRoutes.teams` (`/teams`, name: `teams`, builder: `GroupLandingPage`)
     - Child route: `path: 'daily-log'`, name: `daily-log` (`/teams/daily-log`, builder: `DailyLogListScreen`)
       - Child route: `path: 'form'`, name: `daily-log-form` (`/teams/daily-log/form`, pageBuilder: `DailyLogFormSheet`)
   - When a user on `DailyLogListScreen` taps "Log Baru" (`Key('create_new_daily_log_fab')`), `daily_log_list_screen.dart:190-199` invokes `context.pushNamed('daily-log-form')`.
   - The GoRouter branch navigator stack at this moment has 3 entries:
     `[ /teams, /teams/daily-log, /teams/daily-log/form ]`.
   - Popping once returns to `/teams/daily-log`. Popping twice strips `/teams/daily-log` and lands on `/teams`.

2. **Form Sheet Close Implementation in `daily_log_form_sheet.dart:155-165`**:
   ```dart
   void _handleClose() {
     if (widget.onClose != null) {
       widget.onClose!();
       return;
     }
     if (context.canPop()) {
       context.pop();
     } else {
       // Cold URL without a stack: go to the list, preserving query context.
       context.go(AppRoutes.dailyLog);
     }
   }
   ```
   Notice that `_handleClose()` has **no one-shot latch** (`_hasClosed`).

3. **Asynchronous Success Close in `daily_log_form_sheet.dart:219-230`**:
   ```dart
   if (state.successMessage != null) {
     showFToast(context: context, title: Text(state.successMessage!));
     Future.delayed(const Duration(milliseconds: 600), () {
       if (!mounted || _formRoute?.isCurrent != true) return;
       _handleClose();
     });
   }
   ```
   - A `Future.delayed(const Duration(milliseconds: 600))` timer is scheduled after submit succeeds.
   - The route check `_formRoute?.isCurrent != true` (added in `c982c55`) fails to prevent a second pop if the route is still the top modal route when the timer fires, or if `appRouter.go` has set the router state but the framework has not yet completed unmounting the widget.

4. **Multiple Dismissal Channels**:
   - Success listener (`daily_log_form_sheet.dart:228`) calls `_handleClose()`.
   - `AppResponsiveSheet.onDismissApproved` (`daily_log_form_sheet.dart:308`) calls `_handleClose()`.
   - Unlike `attendance_form_sheet.dart:146` (`bool _hasClosed = false;`), `benchmark_form_screen.dart:147`, `cut_fill_form_screen.dart:140`, and `inventory_item_entry_screen.dart:78`, `DailyLogFormSheet` lacks any latch to guarantee `_handleClose()` is strictly idempotent and executes `context.pop()` at most once.

5. **Test Driver Interaction in `daily_log_journey_test.dart:140-166`**:
   ```dart
   await tester.tap(submitBtn);
   await tester.pumpAndSettle(const Duration(seconds: 2));
   ...
   appRouter.go(AppRoutes.dailyLog);
   await tester.pumpAndSettle();
   ```
   - In integration testing on web/staging, when the remote database submit takes ~1.4s, `tester.pumpAndSettle(const Duration(seconds: 2))` can settle as soon as frame animations quiesce, exiting while the 600ms timer is still pending.
   - The test executes repository read-back checks (lines 143-158) asynchronously.
   - The test then executes `appRouter.go(AppRoutes.dailyLog)` at line 166.
   - Concurrently or immediately after, the 600ms timer fires and calls `_handleClose()`.
   - `_handleClose()` checks `context.canPop()`, which is true at `/teams/daily-log` (it can pop to `/teams`). It executes `context.pop()`, popping `/teams/daily-log` back to `/teams`.
   - Hard evidence from prior probe: `appRouter.state.matchedLocation == '/teams'`.

---

### R2 Observations: Foreman List Visibility & Refresh Trigger
1. **Missing `RouteObserver` on Branch Navigator in `lib/app/router.dart`**:
   - `observers: [routeObserver]` is passed ONLY to root `GoRouter` at line 128:
     ```dart
     final appRouter = GoRouter(
       initialLocation: AppRoutes.login,
       debugLogDiagnostics: true,
       refreshListenable: authRevision,
       observers: [routeObserver],
     ```
   - In `StatefulShellRoute.indexedStack` (lines 179-965), NONE of the 5 branches pass `observers: [routeObserver]`.
   - Specifically, Branch 3 (Teams) at line 600:
     ```dart
     StatefulShellBranch(
       routes: [
         GoRoute(
           path: AppRoutes.teams,
           name: 'teams',
     ```
     `observers:` parameter is completely omitted!
   - In Flutter GoRouter, each branch in `StatefulShellRoute` maintains its own `Navigator`. That branch Navigator uses only its own `branch.observers ?? const []`.
   - Because `routeObserver` is absent from Branch 3, Branch 3's Navigator **never calls `routeObserver.didPop(...)`**.
   - As a direct result, `DailyLogListView.didPopNext()` (line 135) is **never invoked** when returning from `DailyLogFormSheet` in the running application shell!

2. **Race Condition & Silent Event Dropping in `didPopNext`**:
   - `daily_log_list_screen.dart:142-155`:
     ```dart
     final bloc = context.read<DailyLogBloc>();
     final blocState = bloc.state;
     if (blocState is DailyLogsLoaded) {
       bloc.add(
         LoadDailyLogsListEvent(
           siteId: blocState.siteId,
           foremanId: blocState.foremanFilter,
         ),
       );
       if (!widget.isSupervisor &&
           blocState.activeTab == DailyLogReviewTab.draft) {
         bloc.add(const SelectDailyLogTabEvent(DailyLogReviewTab.all));
       }
     }
     ```
   - In `daily_log_bloc.dart:102-125`:
     ```dart
     Future<void> _onLoadDailyLogsList(
       LoadDailyLogsListEvent event,
       Emitter<DailyLogState> emit,
     ) async {
       final prev = state is DailyLogsLoaded ? state as DailyLogsLoaded : null;
       final tab = prev?.activeTab ?? DailyLogReviewTab.all;
       emit(const DailyLogLoading());
       try {
         await _loadList(..., activeTab: tab);
     ```
     `LoadDailyLogsListEvent` immediately emits `const DailyLogLoading()`.
   - In `daily_log_bloc.dart:127-133`:
     ```dart
     Future<void> _onSelectTab(
       SelectDailyLogTabEvent event,
       Emitter<DailyLogState> emit,
     ) async {
       final current = state;
       if (current is! DailyLogsLoaded) return;
     ```
     When `SelectDailyLogTabEvent` begins processing, `state` is `DailyLogLoading()`. Because `current is! DailyLogsLoaded` is true, **`SelectDailyLogTabEvent` returns immediately and is dropped**.
   - When `_onLoadDailyLogsList` completes, it re-emits `DailyLogsLoaded` with `activeTab: tab`, which was `DailyLogReviewTab.draft`.
   - The foreman remains on the `Draft` tab.
   - The created log has status `LogStatus.submitted`, so it is filtered out of `DailyLogReviewTab.draft` (`logs: all.where((l) => l.status == LogStatus.draft)`).
   - Thus, the newly submitted log is absent from the visible card list.

3. **`DailyLogListScreen._openCreateForm()` Does Not Await `pushNamed`**:
   - `daily_log_list_screen.dart:190-199`:
     ```dart
     void _openCreateForm() {
       context.pushNamed(
         'daily-log-form',
         queryParameters: {
           if (widget.foremanId != null) 'foremanId': widget.foremanId!,
         },
       );
     }
     ```
   - `context.pushNamed` returns a `Future` that completes when the pushed route pops. That `Future` is ignored.

4. **Legacy Re-Navigation in `daily_log_journey_test.dart:166` Resets the BLoC**:
   - `daily_log_journey_test.dart:166`:
     ```dart
     appRouter.go(AppRoutes.dailyLog);
     await tester.pumpAndSettle();
     ```
   - Calling `appRouter.go(AppRoutes.dailyLog)` forces GoRouter to rebuild `DailyLogListScreen`.
   - In `daily_log_list_screen.dart:69-82`:
     ```dart
     return BlocProvider(
       create: (context) => DailyLogBloc(repository: repository)
         ..add(LoadDailyLogsListEvent(siteId: siteId, foremanId: foremanId))
         ..add(SelectDailyLogTabEvent(defaultTab)),
     ```
   - A new `DailyLogBloc` is created with `defaultTab = DailyLogReviewTab.draft` (for foreman).
   - Even if the UI had previously widened to `Semua`, `appRouter.go` resets the active tab back to `Draft`, where submitted logs are hidden (`find.text(testSummary)` = 0).

---

## 2. Logic Chain

### Logic Chain for R1 (Double-Pop / Landing on `/teams`)
1. **Observation 1 & 2**: Route structure is `/teams` -> `/teams/daily-log` -> `/teams/daily-log/form`. A single `pop()` returns to `/teams/daily-log`. Two `pop()` calls strip `/teams/daily-log` and land on `/teams`.
2. **Observation 3 & 4**: `DailyLogFormSheetView` has no `_hasClosed` latch and schedules an unmanaged asynchronous timer: `Future.delayed(600ms, _handleClose)`.
3. **Observation 5**: In `daily_log_journey_test.dart`, `pumpAndSettle(2s)` finishes, step 9 executes async I/O, and step 10 executes `appRouter.go(AppRoutes.dailyLog)` at line 166.
4. **Inference**: If the delayed timer fires after or during `appRouter.go(AppRoutes.dailyLog)`, `_handleClose()` calls `context.pop()`. Because the router is already at `/teams/daily-log`, popping that route navigates back to `/teams`.
5. **Inference**: Furthermore, if both `state.successMessage` listener and `AppResponsiveSheet.onDismissApproved` trigger, or if `PopScope` triggers dismissal, both call `_handleClose()`. Without `_hasClosed = true`, two pops occur.
6. **Conclusion R1**: The fix requires:
   - Adding a one-shot `bool _hasClosed = false;` latch to `DailyLogFormSheetView._handleClose()`.
   - Removing the 600ms delayed timer and invoking `_handleClose()` immediately on `successMessage != null` (matching `attendance_form_sheet.dart`). `showFToast` is rendered in the global application overlay, so the toast persists across route transitions without needing an arbitrary sheet delay.

### Logic Chain for R2 (List Visibility / `find.text(testSummary)` = 0)
1. **Observation R2.1**: `lib/app/router.dart:600` omits `observers: [routeObserver]` on `StatefulShellBranch`. Therefore, inner route pops in Branch 3 never notify `routeObserver`, and `didPopNext()` never executes in production or E2E tests.
2. **Observation R2.2**: In `didPopNext()`, two separate events are dispatched: `LoadDailyLogsListEvent` followed by `SelectDailyLogTabEvent`. `LoadDailyLogsListEvent` immediately transitions state to `DailyLogLoading`. `SelectDailyLogTabEvent` explicitly drops itself when state is not `DailyLogsLoaded`. Consequently, the tab switch to `DailyLogReviewTab.all` is discarded, and the BLoC remains on `DailyLogReviewTab.draft`.
3. **Observation R2.3**: In `DailyLogReviewTab.draft`, `logs` are filtered to `status == LogStatus.draft`. The created log has `LogStatus.submitted`, so it is excluded from the list.
4. **Observation R2.4**: In `daily_log_journey_test.dart:166`, `appRouter.go(AppRoutes.dailyLog)` is called. This legacy call rebuilds `DailyLogListScreen`, creating a fresh `DailyLogBloc` that re-initializes to `defaultTab` (`DailyLogReviewTab.draft`), guaranteeing that the tab is `Draft` and the submitted log is hidden.
5. **Conclusion R2**: The fix requires:
   - Adding `observers: [routeObserver]` to `StatefulShellBranch` in `lib/app/router.dart`.
   - Adding `final DailyLogReviewTab? tab;` to `LoadDailyLogsListEvent` so that reloading data and setting the active tab to `Semua` (`DailyLogReviewTab.all`) is an atomic BLoC transition.
   - Updating `_openCreateForm` to `await context.pushNamed(...)` and refresh the list atomically.
   - Updating `daily_log_journey_test.dart` to remove the destructive `appRouter.go(AppRoutes.dailyLog)` and instead await the sheet dismissal naturally (matching `attendance_journey_test.dart`).

---

## 3. Caveats

1. **Staging Environment Credentials**: The E2E test `daily_log_journey_test.dart` requires foreman credentials (`TEST_FOREMAN_EMAIL`, `TEST_FOREMAN_PASSWORD`) in `.env` to execute against staging Supabase without skipping.
2. **Untracked Local Scratch**: Existing untracked files (`.step55.11h-run-web.sh`, `run_web_wrapper.dart`, etc.) must not be deleted or staged.
3. **Immutable Migration SQL**: Migration SQL files are strictly immutable; schema and contract guards are already passing.

---

## 4. Conclusion & Concrete Fix Instructions for Worker

### Modification 1: `lib/features/daily_log/presentation/pages/daily_log_form_sheet.dart`
1. In `_DailyLogFormSheetViewState`:
   Add `bool _hasClosed = false;`.
2. Update `_handleClose()`:
   ```dart
   bool _hasClosed = false;

   void _handleClose() {
     if (_hasClosed) return;
     _hasClosed = true;
     if (widget.onClose != null) {
       widget.onClose!();
       return;
     }
     if (context.canPop()) {
       context.pop();
     } else {
       // Cold URL without a stack: go to the list, preserving query context.
       context.go(AppRoutes.dailyLog);
     }
   }
   ```
3. Update the `BlocConsumer` listener (around lines 219-230):
   Replace the `Future.delayed(600ms)` callback with an immediate one-shot close:
   ```dart
   if (state.successMessage != null) {
     if (_hasClosed) return;
     _hasClosed = true;
     showFToast(context: context, title: Text(state.successMessage!));
     _handleClose();
   }
   ```

### Modification 2: `lib/app/router.dart`
At line 600 (Branch 3: Teams), and on all other `StatefulShellBranch` declarations (lines 190, 214, 316, 963):
Add `observers: [routeObserver]`:
```dart
StatefulShellBranch(
  observers: [routeObserver],
  routes: [
    GoRoute(
      path: AppRoutes.teams,
      name: 'teams',
...
```

### Modification 3: `lib/features/daily_log/presentation/bloc/daily_log_event.dart`
Update `LoadDailyLogsListEvent` to accept an optional `tab`:
```dart
class LoadDailyLogsListEvent extends DailyLogEvent {
  final DateTime? date;
  final String? siteId;
  final String? foremanId;
  final LogStatus? statusFilter;
  final DailyLogReviewTab? tab;

  const LoadDailyLogsListEvent({
    this.date,
    this.siteId,
    this.foremanId,
    this.statusFilter,
    this.tab,
  });

  @override
  List<Object?> get props => [date, siteId, foremanId, statusFilter, tab];
}
```

### Modification 4: `lib/features/daily_log/presentation/bloc/daily_log_bloc.dart`
In `_onLoadDailyLogsList` (lines 102-125), respect `event.tab`:
```dart
  Future<void> _onLoadDailyLogsList(
    LoadDailyLogsListEvent event,
    Emitter<DailyLogState> emit,
  ) async {
    final prev = state is DailyLogsLoaded ? state as DailyLogsLoaded : null;
    final tab = event.tab ?? prev?.activeTab ?? DailyLogReviewTab.all;
    emit(const DailyLogLoading());
    try {
      await _loadList(
        emit,
        date: event.date ?? prev?.selectedDate,
        siteId: event.siteId ?? prev?.siteId,
        foremanId: event.foremanId ?? prev?.foremanFilter,
        activeTab: tab,
        zoneFilter: prev?.zoneFilter,
        foremanFilter: prev?.foremanFilter,
      );
    } catch (e) {
      emit(DailyLogError('Gagal memuat log harian: ${e.toString()}'));
    }
  }
```

### Modification 5: `lib/features/daily_log/presentation/pages/daily_log_list_screen.dart`
1. Add `_refreshListAndWidenToAll()` helper:
   ```dart
   void _refreshListAndWidenToAll() {
     final bloc = context.read<DailyLogBloc>();
     final blocState = bloc.state;
     final targetTab = (!widget.isSupervisor &&
             (blocState is! DailyLogsLoaded ||
                 blocState.activeTab == DailyLogReviewTab.draft))
         ? DailyLogReviewTab.all
         : (blocState is DailyLogsLoaded
             ? blocState.activeTab
             : DailyLogReviewTab.all);

     bloc.add(
       LoadDailyLogsListEvent(
         siteId: blocState is DailyLogsLoaded ? blocState.siteId : widget.siteId,
         foremanId: blocState is DailyLogsLoaded
             ? blocState.foremanFilter
             : widget.foremanId,
         tab: targetTab,
       ),
     );
   }
   ```
2. In `didPopNext()`:
   ```dart
   @override
   void didPopNext() {
     _refreshListAndWidenToAll();
   }
   ```
3. In `_openCreateForm()`:
   ```dart
   Future<void> _openCreateForm() async {
     await context.pushNamed(
       'daily-log-form',
       queryParameters: {
         if (widget.foremanId != null) 'foremanId': widget.foremanId!,
       },
     );
     if (mounted) {
       _refreshListAndWidenToAll();
     }
   }
   ```

### Modification 6: `integration_test/journeys/daily_log_journey_test.dart`
At step 10 (lines 160-175):
Replace `appRouter.go(AppRoutes.dailyLog);` with the polling wait for the form sheet pop:
```dart
        // 10. Verify visibility on DailyLogListScreen (CF-006 guard: not hidden by empty foremanId).
        // The form sheet pops itself on submit, returning to DailyLogListScreen.
        for (
          var i = 0;
          i < 50 && find.byType(DailyLogListScreen).evaluate().isEmpty;
          i++
        ) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        await tester.pumpAndSettle();

        expect(find.byType(DailyLogListScreen), findsOneWidget);
        expect(find.byType(DailyLogCard), findsWidgets);
```

---

## 5. Verification Method

To verify the fix independently, execute the following commands in `Code/mine-flow-app`:

1. **Unit & Widget Test Suites**:
   ```bash
   flutter test test/unit/hazard_assessment_test.dart test/unit/daily_log_repository_test.dart test/widget/daily_log_screen_test.dart test/features/daily_log/
   ```
   *Expected:* All 63 tests pass with 0 failures.

2. **Supabase Contract Guard**:
   ```bash
   dart run tool/check_supabase_contracts.dart
   ```
   *Expected:* Exit code 0, `[OK] Contract verification passed.`

3. **Static Analysis & Formatting**:
   ```bash
   flutter analyze lib/features/daily_log/ lib/app/router.dart
   dart format --output=none --set-exit-if-changed lib/features/daily_log/ lib/app/router.dart integration_test/journeys/daily_log_journey_test.dart
   ```
   *Expected:* 0 warnings/errors, 0 changed files.

4. **Integration Test Repro**:
   ```bash
   flutter test integration_test/journeys/daily_log_journey_test.dart
   ```
   *Expected:* Both line `:169` `DailyLogListScreen` and `:183` / `:203` `testSummary` card assertions pass completely without double-pop or missing card error.
