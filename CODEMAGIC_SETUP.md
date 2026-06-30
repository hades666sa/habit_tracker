# Codemagic Setup Guide for Habit Tracker Flutter

## 🚀 Quick Start (No Mac Needed)

### 1. Connect Repository
1. Go to **https://codemagic.io/**
2. Sign up with **GitHub**
3. Click **"Add application"** → Select your repo
4. Choose **"Flutter App"** → **"codemagic.yaml"**

### 2. Configure Environment Variables
Go to **App Settings → Environment variables** (🔒 Secure)

| Variable | Value | Description |
|----------|-------|-------------|
| `KEYCHAIN_PASSWORD` | `your-mac-keychain-password` | Temporary keychain password for CI |
| `CERTIFICATE_P12_BASE64` | `base64-encoded-.p12-file` | Distribution certificate (base64) |
| `CERTIFICATE_PASSWORD` | `p12-file-password` | Password for .p12 file |
| `PROVISIONING_PROFILE_MAIN_BASE64` | `base64-encoded-.mobileprovision` | Main app provisioning profile |
| `PROVISIONING_PROFILE_WIDGET_BASE64` | `base64-encoded-.mobileprovision` | Widget extension provisioning profile |
| `ASC_API_KEY_ID` | `ABC123XYZ` | App Store Connect API Key ID |
| `ASC_API_KEY_ISSUER` | `12345678-...` | App Store Connect API Issuer ID |
| `ASC_API_KEY_CONTENT` | `base64-encoded-.p8-file` | App Store Connect API private key |

### 3. Get Required Files (One-time on any Mac)

#### A. Distribution Certificate (.p12)
```bash
# On Mac with Xcode:
# 1. Open Keychain Access
# 2. Find "Apple Distribution: Your Name (TEAM_ID)"
# 3. Right-click → Export → Save as .p12
# 4. base64 -i certificate.p12 | pbcopy
```

#### B. Provisioning Profiles (.mobileprovision)
```bash
# Download from Apple Developer Portal:
# 1. Certificates, Identifiers & Profiles → Profiles
# 2. Create 2 profiles: "App Store" for:
#    - com.loop.habittracker.habitTrackerFlutter (main app)
#    - com.loop.habittracker.habitTrackerFlutter.HabitWidgetExtension (widget)
# 3. Download both → base64 encode each:
base64 -i main.mobileprovision | pbcopy
base64 -i widget.mobileprovision | pbcopy
```

#### C. App Store Connect API Key
1. **App Store Connect → Users & Access → Keys**
2. Create key with **App Manager** or **Admin** role
3. Download `.p8` file (only once!)
4. `base64 -i AuthKey_XXX.p8 | pbcopy`
5. Note: **Key ID** and **Issuer ID** from same page

### 4. First Build
1. Push to `main` branch
2. Codemagic auto-triggers `ios-build` + `android-build` + `web-build`
3. Check build logs for any issues

### 5. TestFlight Release
```bash
# Create release branch or tag:
git checkout -b release/v1.0.0
git push origin release/v1.0.0
# OR
git tag v1.0.0 && git push origin v1.0.0
```
This triggers `ios-release` workflow → uploads to TestFlight automatically.

---

## 📱 Widget Extension - Auto-Configured

Codemagic **automatically handles**:
- ✅ Widget Extension target detection
- ✅ App Groups entitlement (`group.com.loop.habittracker.habit_tracker_flutter`)
- ✅ Bundle ID: `com.loop.habittracker.habitTrackerFlutter.HabitWidgetExtension`
- ✅ Code signing for both targets
- ✅ Archive includes both app + widget

**No Xcode project editing needed!**

---

## 🔧 Troubleshooting

| Issue | Solution |
|-------|----------|
| "Provisioning profile doesn't match" | Verify bundle IDs in profiles match exactly |
| "Certificate not found" | Ensure .p12 imported to keychain in script |
| "Widget not in archive" | Codemagic auto-detects - check build logs |
| "App Store Connect API failed" | Verify API key has App Manager+ role |
| "Flutter version mismatch" | Set `flutter: stable` or specific version in yaml |

---

## 💰 Costs

| Tier | Build Minutes | Concurrent Builds |
|------|--------------|-------------------|
| **Free** | 500/month | 1 |
| **Pro** | Unlimited | 2+ |

Free tier covers ~8-10 iOS builds/month.

---

## 📋 Checklist Before First Build

- [ ] Repository connected to Codemagic
- [ ] `codemagic.yaml` detected (in root)
- [ ] All 8 environment variables added (secure)
- [ ] Apple Developer account has:
  - [ ] Distribution certificate
  - [ ] 2 App Store provisioning profiles (app + widget)
  - [ ] App Store Connect API key
- [ ] Push to `main` triggers build

---

## 🎯 What You Get

| Platform | Artifact | Deploy |
|----------|----------|--------|
| **iOS** | Debug .app + Release .ipa | TestFlight (on tag/release branch) |
| **Android** | Debug + Release .apk | Email artifact / Play Console (manual) |
| **Web** | `build/web/` folder | Netlify/Vercel/Firebase (manual upload) |

---

## 🆘 Support

- Codemagic docs: https://docs.codemagic.io/
- Flutter iOS: https://docs.flutter.dev/deployment/ios
- Widget extension: https://developer.apple.com/documentation/widgetkit

**No Mac required after initial certificate setup (which can be done on any Mac once).**