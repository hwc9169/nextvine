# Google Sign-In Setup Instructions

## 1. Google Cloud Console Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the Google Sign-In API:
   - Go to "APIs & Services" > "Library"
   - Search for "Google Sign-In API" and enable it

## 2. Configure OAuth Consent Screen

1. Go to "APIs & Services" > "OAuth consent screen"
2. Choose "External" user type
3. Fill in the required information:
   - App name: NextVine
   - User support email: your-email@domain.com
   - Developer contact information: your-email@domain.com
4. Add scopes:
   - `../auth/userinfo.email`
   - `../auth/userinfo.profile`
   - `openid`

## 3. Create OAuth 2.0 Credentials

1. Go to "APIs & Services" > "Credentials"
2. Click "Create Credentials" > "OAuth 2.0 Client IDs"
3. Choose "Android" as application type
4. Fill in the details:
   - Name: NextVine Android
   - Package name: `ai.nextvine.scoliosis`
   - SHA-1 certificate fingerprint: (see below for how to get this)

## 4. Get SHA-1 Certificate Fingerprint

### For Debug (Development):
```bash
cd android/app
keytool -list -v -keystore debug.keystore -alias androiddebugkey -storepass android -keypass android
```

### For Release (Production):
```bash
keytool -list -v -keystore your-release-key.keystore -alias your-key-alias
```

## 5. Download google-services.json

1. In Google Cloud Console, go to "Project Settings"
2. Download the `google-services.json` file
3. Replace the sample file in `android/app/google-services.json` with your actual file

## 6. Update Dependencies

The required dependencies are already added to `pubspec.yaml`:
- `google_sign_in: ^6.2.1`
- `googleapis: ^14.0.0`
- `googleapis_auth: ^2.0.0`

## 7. Android Configuration

The following configurations are already added to `android/app/src/main/AndroidManifest.xml`:
- Internet permissions
- Google Play Services metadata

## 8. Test the Implementation

1. Run the app: `flutter run`
2. You should see the login screen with a "Sign in with Google" button
3. Tap the button to test Google Sign-In functionality

## Troubleshooting

### Common Issues:

1. **"Sign-in failed with status code 10"**
   - Check that your package name matches exactly
   - Verify SHA-1 fingerprint is correct
   - Ensure google-services.json is in the correct location

2. **"Sign-in failed with status code 7"**
   - Check that the Google Sign-In API is enabled
   - Verify OAuth consent screen is configured

3. **"Network error"**
   - Check internet connectivity
   - Verify API key is correct in google-services.json

### Debug Steps:

1. Check logs: `flutter logs`
2. Verify google-services.json format
3. Test with a fresh Google account
4. Clear app data and try again

## Production Considerations

1. Create a release keystore
2. Add the release SHA-1 fingerprint to Google Cloud Console
3. Configure OAuth consent screen for production
4. Test with production google-services.json
5. Consider adding error handling for network issues
6. Implement proper user data privacy compliance
