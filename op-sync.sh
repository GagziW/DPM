#!/usr/bin/env bash
# Regenerate every machine-local secret file from 1Password (vault DPM).
# Run on EACH machine (MacBook Pro + Mac mini) after `op signin`.
# 1Password is the source of truth; the files this writes are disposable,
# gitignored artifacts. Idempotent — safe to re-run anytime.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
V=DPM

command -v op >/dev/null 2>&1 || { echo "❌ install 1Password CLI: brew install 1password-cli"; exit 1; }
op whoami >/dev/null 2>&1 || { echo "❌ not signed in — run: op signin"; exit 1; }

echo "→ .env files (op inject)"
op inject -f -i "$ROOT/DPM.org/.env.local.tpl"    -o "$ROOT/DPM.org/.env.local"
op inject -f -i "$ROOT/DPM_admin_board/.env.local.tpl" -o "$ROOT/DPM_admin_board/.env.local"

echo "→ iOS Secrets.xcconfig (op inject) — fixes QuickPose + publishable keys"
op inject -f -i "$ROOT/DPMSwift/Dopamining/Configurations/Secrets.xcconfig.tpl" \
             -o "$ROOT/DPMSwift/Dopamining/Configurations/Secrets.xcconfig"

echo "→ document files (op document get)"
mkdir -p "$ROOT/DPM_cloud_functions/keys" "$ROOT/DPMAndroid/app"
op document get "AppleSignInKey"        --vault $V --force --out-file "$ROOT/DPM_cloud_functions/keys/AuthKey_ZWBH3WGR95.p8"
op document get "FirebaseConfigIos"     --vault $V --force --out-file "$ROOT/DPMSwift/Dopamining/Configurations/GoogleService-Info.plist"
op document get "FirebaseConfigAndroid" --vault $V --force --out-file "$ROOT/DPMAndroid/app/google-services.json"
op document get "AppleProvisioningApp"     --vault $V --force --out-file "$ROOT/DPMSwift/AppStore_io.dopamining.DopamorningApp.mobileprovision"
op document get "AppleProvisioningWidgets" --vault $V --force --out-file "$ROOT/DPMSwift/AppStore_io.dopamining.DopamorningApp.DopaminingWidgets.mobileprovision"

echo ""
echo "✅ Local secret files regenerated from 1Password on this machine."
echo ""
echo "Cloud Functions do NOT read these files — they use Secret Manager. Set those once"
echo "(from either machine), pasting values from 1Password, then redeploy:"
echo "  op read \"op://DPM/StripeLive/SecretKey\"     | firebase functions:secrets:set STRIPE_LIVE_SECRET_KEY     --data-file -"
echo "  op read \"op://DPM/StripeTest/SecretKey\"     | firebase functions:secrets:set STRIPE_TEST_SECRET_KEY     --data-file -"
echo "  op read \"op://DPM/StripeLive/WebhookSecret\" | firebase functions:secrets:set STRIPE_WEBHOOK_SECRET      --data-file -"
echo "  op read \"op://DPM/StripeTest/WebhookSecret\" | firebase functions:secrets:set STRIPE_WEBHOOK_SECRET_TEST --data-file -"
echo "  ( cd \"$ROOT\" && npm --prefix DPM_cloud_functions run deploy )"
