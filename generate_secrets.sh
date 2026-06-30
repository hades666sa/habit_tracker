#!/bin/bash
# Helper script to base64 encode files for Codemagic environment variables
# Run this ONCE on any Mac after downloading certificates/profiles from Apple Developer Portal

set -e

echo "📱 Codemagic Secrets Generator"
echo "=============================="
echo ""

# Distribution Certificate (.p12)
if [ -f "certificate.p12" ]; then
    echo "📄 Encoding certificate.p12..."
    base64 -i certificate.p12 | pbcopy
    echo "✅ CERTIFICATE_P12_BASE64 copied to clipboard"
    echo "   Paste into Codemagic env var: CERTIFICATE_P12_BASE64"
    echo ""
    read -p "Press Enter to continue..."
fi

# Main App Provisioning Profile
if [ -f "main.mobileprovision" ]; then
    echo "📄 Encoding main.mobileprovision..."
    base64 -i main.mobileprovision | pbcopy
    echo "✅ PROVISIONING_PROFILE_MAIN_BASE64 copied to clipboard"
    echo "   Paste into Codemagic env var: PROVISIONING_PROFILE_MAIN_BASE64"
    echo ""
    read -p "Press Enter to continue..."
fi

# Widget Extension Provisioning Profile
if [ -f "widget.mobileprovision" ]; then
    echo "📄 Encoding widget.mobileprovision..."
    base64 -i widget.mobileprovision | pbcopy
    echo "✅ PROVISIONING_PROFILE_WIDGET_BASE64 copied to clipboard"
    echo "   Paste into Codemagic env var: PROVISIONING_PROFILE_WIDGET_BASE64"
    echo ""
    read -p "Press Enter to continue..."
fi

# App Store Connect API Key (.p8)
if [ -f "AuthKey_*.p8" ]; then
    API_KEY=$(ls AuthKey_*.p8 | head -1)
    echo "📄 Encoding $API_KEY..."
    base64 -i "$API_KEY" | pbcopy
    echo "✅ ASC_API_KEY_CONTENT copied to clipboard"
    echo "   Paste into Codemagic env var: ASC_API_KEY_CONTENT"
    echo ""
    read -p "Press Enter to continue..."
fi

echo ""
echo "🎉 All secrets generated! Don't forget to also set these in Codemagic:"
echo "   - CERTIFICATE_PASSWORD (your .p12 password)"
echo "   - KEYCHAIN_PASSWORD (temporary, e.g. 'temp123')"
echo "   - ASC_API_KEY_ID (from App Store Connect)"
echo "   - ASC_API_KEY_ISSUER (from App Store Connect)"
echo ""
echo "📋 Files needed in this folder:"
echo "   - certificate.p12 (Distribution cert export from Keychain)"
echo "   - main.mobileprovision (App Store profile for main app)"
echo "   - widget.mobileprovision (App Store profile for widget extension)"
echo "   - AuthKey_XXXXXX.p8 (App Store Connect API key)"