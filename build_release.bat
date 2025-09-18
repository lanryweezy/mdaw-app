@echo off
echo 🎵 Studio Wiz - Release Build Script
echo ====================================

REM Check if Flutter is installed
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter is not installed or not in PATH
    echo Please install Flutter from https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

echo ✅ Flutter found

REM Clean previous builds
echo.
echo 🧹 Cleaning previous builds...
flutter clean
flutter pub get

REM Run tests
echo.
echo 🧪 Running tests...
flutter test
if %errorlevel% neq 0 (
    echo ❌ Tests failed. Please fix issues before building release.
    pause
    exit /b 1
)

REM Analyze code
echo.
echo 🔍 Analyzing code...
flutter analyze
if %errorlevel% neq 0 (
    echo ⚠️  Code analysis found issues. Continuing with build...
)

REM Create app icons
echo.
echo 🎨 Creating app icons...
python create_app_icons.py
if %errorlevel% neq 0 (
    echo ⚠️  Could not create app icons. Make sure Python and Pillow are installed.
    echo Install with: pip install Pillow
)

REM Build for Android
echo.
echo 📱 Building Android APK...
flutter build apk --release
if %errorlevel% neq 0 (
    echo ❌ Android build failed
    pause
    exit /b 1
)

REM Build Android App Bundle
echo.
echo 📦 Building Android App Bundle...
flutter build appbundle --release
if %errorlevel% neq 0 (
    echo ❌ Android App Bundle build failed
    pause
    exit /b 1
)

REM Build for Windows
echo.
echo 🖥️  Building Windows executable...
flutter build windows --release
if %errorlevel% neq 0 (
    echo ❌ Windows build failed
    pause
    exit /b 1
)

REM Build for Web
echo.
echo 🌐 Building Web version...
flutter build web --release
if %errorlevel% neq 0 (
    echo ❌ Web build failed
    pause
    exit /b 1
)

echo.
echo ✅ All builds completed successfully!
echo.
echo 📁 Build outputs:
echo    • Android APK: build\app\outputs\flutter-apk\app-release.apk
echo    • Android AAB: build\app\outputs\bundle\release\app-release.aab
echo    • Windows: build\windows\x64\runner\Release\
echo    • Web: build\web\
echo.
echo 🚀 Ready for deployment to app stores!
echo.
echo Next steps:
echo 1. Test the builds on target devices
echo 2. Upload to Google Play Console (Android)
echo 3. Upload to Microsoft Store (Windows)
echo 4. Deploy web version to hosting service
echo 5. Submit for review
echo.
pause

