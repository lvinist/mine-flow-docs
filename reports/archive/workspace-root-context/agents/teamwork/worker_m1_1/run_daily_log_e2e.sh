#!/usr/bin/env bash
set -u
cd /d/AppDev/mine_flow/Code/mine-flow-app
export FLUTTER_TEST_TIMEOUT=1500

declare -A ENVV
while IFS='=' read -r k v; do
  [[ -z "$k" || "$k" =~ ^[[:space:]]*# ]] && continue
  k="${k%"${k##*[![:space:]]}"}"; k="${k#"${k%%[![:space:]]*}"}"
  [[ -z "$k" ]] && continue
  ENVV["$k"]="$v"
done < .env

echo "import 'integration_test/journeys/daily_log_journey_test.dart' as test_main; void main() => test_main.main();" > run_web_wrapper.dart

flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=run_web_wrapper.dart \
  -d web-server \
  --browser-name=chrome \
  --dart-define=SUPABASE_URL="${ENVV[SUPABASE_URL]:-}" \
  --dart-define=SUPABASE_ANON_KEY="${ENVV[SUPABASE_ANON_KEY]:-}" \
  --dart-define=APP_ENV=staging \
  --dart-define=TEST_USER_EMAIL="${ENVV[TEST_USER_EMAIL]:-}" \
  --dart-define=TEST_USER_PASSWORD="${ENVV[TEST_USER_PASSWORD]:-}" \
  --dart-define=TEST_SUPERVISOR_EMAIL="${ENVV[TEST_SUPERVISOR_EMAIL]:-}" \
  --dart-define=TEST_SUPERVISOR_PASSWORD="${ENVV[TEST_SUPERVISOR_PASSWORD]:-}" \
  --dart-define=TEST_FOREMAN_EMAIL="${ENVV[TEST_FOREMAN_EMAIL]:-}" \
  --dart-define=TEST_FOREMAN_PASSWORD="${ENVV[TEST_FOREMAN_PASSWORD]:-}" \
  --dart-define=TEST_CREW_EMAIL="${ENVV[TEST_CREW_EMAIL]:-}" \
  --dart-define=TEST_CREW_PASSWORD="${ENVV[TEST_CREW_PASSWORD]:-}"
