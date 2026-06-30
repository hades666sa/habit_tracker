# iOS Setup Guide - One-Time Xcode Configuration Required

## ⚠️ IMPORTANT: This Requires a Mac with Xcode (One Time Only)

Since you don't have a Mac, you have **3 options**:

| Option | Cost | Time | Best For |
|--------|------|------|----------|
| **Borrow a Mac** | Free | 30 min | One-time setup |
| **GitHub Codespaces (macOS)** | Free tier | 15 min | Quick setup |
| **MacStadium/AWS Mac** | ~$50-100/mo | Ongoing | Regular iOS development |

---

## 📋 What Needs to Be Done in Xcode (One Time)

### 1. Add Widget Extension Target
1. Open `ios/Runner.xcworkspace` in Xcode
2. **File → New → Target → Widget Extension**
3. Name: `HabitWidgetExtension`
4. **Uncheck** "Include Configuration Intent"
5. Click **Finish** → **Activate** scheme

### 2. Configure App Groups (Both Targets)
For **Runner** AND **HabitWidgetExtension** targets:
1. Select target → **Signing & Capabilities**
2. Click **+ Capability** → **App Groups**
3. Add: `group.com.loop.habittracker.habit_tracker_flutter`
4. Enable the checkbox

### 3. Set Deployment Targets
- **Runner**: iOS 13.0+ (already configured)
- **HabitWidgetExtension**: iOS 14.0+ (WidgetKit minimum)

### 4. Verify Bundle Identifiers
- Runner: `com.loop.habittracker.habitTrackerFlutter`
- Widget: `com.loop.habittracker.habitTrackerFlutter.HabitWidgetExtension`

### 5. Commit & Push Changes
```bash
git add ios/Runner.xcodeproj/project.pbxproj ios/Runner.xcworkspace/
git commit -m "feat: Add iOS widget extension target and App Groups"
git push
```

---

## 🔐 GitHub Secrets Required (Configure Once)

Go to: **GitHub Repo → Settings → Secrets and Variables → Actions → New Repository Secret**

| Secret Name | Value | How to Get |
|-------------|-------|------------|
| `MATCH_GIT_URL` | `git@github.com:your-org/certificates.git` | Private repo for certs |
| `MATCH_PASSWORD` | `your-match-password` | Encryption password for match |
| `APP_STORE_CONNECT_API_KEY_ID` | `ABC123XYZ` | App Store Connect → Users → Keys |
| `APP_STORE_CONNECT_API_KEY_ISSUER` | `12345678-1234-1234-1234-123456789012` | Same page as above |
| `APP_STORE_CONNECT_API_KEY_CONTENT` | `-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----` | Download .p8 file, base64 encode |

### Quick Setup for Certificates (match):
```bash
# On a Mac (one time):
git clone git@github.com:your-org/certificates.git
cd certificates
# Add your Apple Developer certificates
git add . && git commit -m "Add certs" && git push
```

---

## 🚀 How to Trigger Builds

### Automatic (on push to main):
```bash
git push origin main
```

### Manual (with TestFlight deploy):
1. Go to **GitHub → Actions → iOS Build & Deploy**
2. Click **Run workflow**
3. Check **Deploy to TestFlight** → **Run workflow**

### Tag Release (auto-deploys to TestFlight):
```bash
git tag v1.0.1
git push origin v1.0.1
```

---

## 📱 Widget Extension Files Already Created

| File | Purpose |
|------|---------|
| `ios/HabitWidgetExtension/HabitWidget.swift` | Widget UI, TimelineProvider, Bundle |
| `ios/HabitWidgetExtension/Info.plist` | Extension config, App Group |

These are **ready to use** once the Xcode target is added.

---

## 🛠️ CI/CD Files Created

| File | Purpose |
|------|---------|
| `.github/workflows/ios-build.yml` | Build, archive, deploy to TestFlight |
| `ios/fastlane/Fastfile` | Certificate management, build, deploy lanes |
| `ios/ExportOptions.plist` | Xcode export configuration |

---

## ✅ Verification Checklist

After completing Xcode setup and pushing:

- [ ] GitHub Actions workflow runs successfully
- [ ] Debug build artifact uploaded (non-release builds)
- [ ] Release build creates IPA (when triggered)
- [ ] TestFlight upload works (with secrets configured)
- [ ] Widget appears in iOS Simulator widget gallery
- [ ] App Group data sync works (complete habit → check widget)

---

## 🆘 Troubleshooting

| Error | Solution |
|-------|----------|
| "No provisioning profile found" | Run `fastlane match` locally or ensure MATCH secrets are correct |
| "Widget not appearing" | Verify App Group ID matches exactly in both targets |
| "Build failed: Widget target not found" | Xcode target not added - complete step 1 above |
| "Code signing error" | Ensure both targets use same Team ID and match profiles |

---

## 💡 Alternative: Codemagic (No GitHub Actions)

If GitHub Actions is complex, use **Codemagic** (Flutter-native CI):
1. Connect repo at codemagic.io
2. Add iOS workflow with widget extension
3. Configure code signing in UI
4. Automatic TestFlight deploy

**Codemagic handles Xcode project setup automatically** for Flutter projects.

---

## 📞 Need Help?

The one-time Xcode setup (~30 min) is the only blocker. Once done:
- ✅ GitHub Actions builds iOS automatically
- ✅ TestFlight deploys on tag push
- ✅ Widgets work on iOS 14+
- ✅ No Mac needed for future builds

**Recommendation**: Borrow a Mac for 30 minutes, complete the Xcode steps above, then everything runs in CI automatically.