# DISPATCH

## 2026-09-23T13:32:43Z

You are swe_3, the SWE Light orchestrator for the Windhawk TopBar fork mod battery enhancement.
Your working directory is: d:/AppDev/mine_flow/.agents/swe_3
Your workspace directory is: d:/AppDev/mine_flow
The authoritative user request is recorded in: d:/AppDev/mine_flow/.agents/ORIGINAL_REQUEST.md

Task Details:
This is a single self-contained fix; keep it small and focused.
Implement energy saver button, power profile selection, power settings shortcut, and dynamic battery icon colors for the Windhawk TopBar fork mod.

Working directory: d:/AppDev/mine_flow
Integrity mode: development

Requirements:
### R1. Dynamic Battery Icon Colors & State Priority
- Battery icon shell fill color must reflect power status with the following priority:
  1. Charging: Green (`#34C759`), retaining the bolt glyph.
  2. Not charging and battery percentage < 20%: Red (`#FF3B30`), no bolt glyph (takes priority over battery saver).
  3. Not charging, battery saver active, and battery percentage >= 20%: Orange (`#FF9500`), no bolt glyph.
  4. Not charging, normal operation (battery percentage >= 20%): Green (`#34C759`), no bolt glyph.
- Do not alter the charging bolt glyph behavior: show bolt on charging, hide bolt when not charging.

### R2. Energy Saver Quick Toggle Tile
- In the Battery flyout panel (`PopulateBatteryPanel`), add an Energy Saver toggle tile styled as a QuickToggleTile matching the existing TopBar design language (similar to Dark Mode in the Display flyout).
- Clicking the tile toggles system Energy Saver state and updates the tile visual state (accent color highlight when active).
- Reads and updates Windows energy saver state accurately.

### R3. Power Profile Selection Menu
- In the Battery flyout panel, provide power profile switching among the supported Windows power overlay schemes (Best power efficiency, Balanced, Best performance).
- Presented as a menu / list with a visual checkmark indicating the currently active profile.
- Selecting a profile immediately updates the active Windows power overlay scheme.

### R4. Power Settings Link
- At the bottom of the Battery flyout panel, add a divider followed by a "Power settings" link button that opens `ms-settings:powersleep` (or `ms-settings:batterysaver`).

### R5. Staging and Apply Script
- The modified source code should be generated in a scratch directory, and an apply batch script (`apply_topbar_battery_update.bat`) must be provided to back up `C:\ProgramData\Windhawk\ModsSource\local@windhawk-topbar-fork.wh.cpp` and update it with the new source code.

Verification Resources:
- Source file: `C:\ProgramData\Windhawk\ModsSource\local@windhawk-topbar-fork.wh.cpp`
- Existing deploy script reference: `d:\AppDev\mine_flow\apply_topbar_tray_button.bat`

Acceptance Criteria:
### Battery Icon
- [ ] Battery icon fill is `#34C759` (green) whenever AC line status is online (charging).
- [ ] Battery icon fill is `#FF3B30` (red) when discharging and percentage < 20%.
- [ ] Battery icon fill is `#FF9500` (orange) when discharging and battery saver is active with percentage >= 20%.
- [ ] Battery icon fill is `#34C759` (green) when discharging with percentage >= 20% and battery saver is off.
- [ ] Charging bolt glyph is visible if and only if charging.

### Battery Flyout UI & Functionality
- [ ] Energy Saver quick toggle tile is present in `PopulateBatteryPanel()`, displays current state, and toggles Energy Saver on click.
- [ ] Power profile selector displays available modes (Best power efficiency, Balanced, Best performance) with a checkmark on the currently active mode, and successfully changes the active power overlay scheme when selected.
- [ ] Divider and "Power settings" link appear at the bottom of the panel and trigger the Settings app URI.

### Safe Deployment
- [ ] Modified file compiles cleanly without syntax errors or missing symbol errors.
- [ ] Apply batch script safely backs up `local@windhawk-topbar-fork.wh.cpp` to `.bak` and updates the file cleanly.

Record your progress in d:/AppDev/mine_flow/.agents/swe_3/progress.md and write your completion handoff report to d:/AppDev/mine_flow/.agents/swe_3/handoff.md. Report victory back when completed.
