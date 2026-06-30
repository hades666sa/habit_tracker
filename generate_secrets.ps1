# Helper script to base64 encode files for Codemagic environment variables
# Run this ONCE on any Mac after downloading certificates/profiles from Apple Developer Portal

Write-Host "📱 Codemagic Secrets Generator (PowerShell)" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Distribution Certificate (.p12)
if (Test-Path "certificate.p12") {
    Write-Host "📄 Encoding certificate.p12..." -ForegroundColor Yellow
    $bytes = [System.IO.File]::ReadAllBytes("certificate.p12")
    $base64 = [System.Convert]::ToBase64String($bytes)
    Set-Clipboard -Value $base64
    Write-Host "✅ CERTIFICATE_P12_BASE64 copied to clipboard" -ForegroundColor Green
    Write-Host "   Paste into Codemagic env var: CERTIFICATE_P12_BASE64"
    Write-Host ""
    Read-Host "Press Enter to continue..."
}

# Main App Provisioning Profile
if (Test-Path "main.mobileprovision") {
    Write-Host "📄 Encoding main.mobileprovision..." -ForegroundColor Yellow
    $bytes = [System.IO.File]::ReadAllBytes("main.mobileprovision")
    $base64 = [System.Convert]::ToBase64String($bytes)
    Set-Clipboard -Value $base64
    Write-Host "✅ PROVISIONING_PROFILE_MAIN_BASE64 copied to clipboard" -ForegroundColor Green
    Write-Host "   Paste into Codemagic env var: PROVISIONING_PROFILE_MAIN_BASE64"
    Write-Host ""
    Read-Host "Press Enter to continue..."
}

# Widget Extension Provisioning Profile
if (Test-Path "widget.mobileprovision") {
    Write-Host "📄 Encoding widget.mobileprovision..." -ForegroundColor Yellow
    $bytes = [System.IO.File]::ReadAllBytes("widget.mobileprovision")
    $base64 = [System.Convert]::ToBase64String($bytes)
    Set-Clipboard -Value $base64
    Write-Host "✅ PROVISIONING_PROFILE_WIDGET_BASE64 copied to clipboard" -ForegroundColor Green
    Write-Host "   Paste into Codemagic env var: PROVISIONING_PROFILE_WIDGET_BASE64"
    Write-Host ""
    Read-Host "Press Enter to continue..."
}

# App Store Connect API Key (.p8)
$apiKeys = Get-ChildItem "AuthKey_*.p8"
if ($apiKeys.Count -gt 0) {
    $apiKey = $apiKeys[0]
    Write-Host "📄 Encoding $($apiKey.Name)..." -ForegroundColor Yellow
    $bytes = [System.IO.File]::ReadAllBytes($apiKey.FullName)
    $base64 = [System.Convert]::ToBase64String($bytes)
    Set-Clipboard -Value $base64
    Write-Host "✅ ASC_API_KEY_CONTENT copied to clipboard" -ForegroundColor Green
    Write-Host "   Paste into Codemagic env var: ASC_API_KEY_CONTENT"
    Write-Host ""
    Read-Host "Press Enter to continue..."
}

Write-Host ""
Write-Host "🎉 All secrets generated!" -ForegroundColor Cyan
Write-Host "Don't forget to also set these in Codemagic:" -ForegroundColor Yellow
Write-Host "   - CERTIFICATE_PASSWORD (your .p12 password)"
Write-Host "   - KEYCHAIN_PASSWORD (temporary, e.g. 'temp123')"
Write-Host "   - ASC_API_KEY_ID (from App Store Connect)"
Write-Host "   - ASC_API_KEY_ISSUER (from App Store Connect)"
Write-Host ""
Write-Host "📋 Files needed in this folder:" -ForegroundColor Yellow
Write-Host "   - certificate.p12 (Distribution cert export from Keychain)"
Write-Host "   - main.mobileprovision (App Store profile for main app)"
Write-Host "   - widget.mobileprovision (App Store profile for widget extension)"
Write-Host "   - AuthKey_XXXXXX.p8 (App Store Connect API key)"