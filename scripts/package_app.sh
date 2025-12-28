#!/bin/bash
set -e

APP_NAME="Voltara"
BUILD_DIR=".build/release"
APP_BUNDLE="${APP_NAME}.app"
SOURCE_ICON="Sources/Voltara/Resources/AppIcon.jpg"

# 1. Build
echo "Building Release configuration..."
swift build -c release

# 2. Create Structure
echo "Creating ${APP_BUNDLE} structure..."
rm -rf "${APP_BUNDLE}"
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

# 3. Copy Executable
echo "Copying executable..."
cp "${BUILD_DIR}/${APP_NAME}" "${APP_BUNDLE}/Contents/MacOS/"

# 4. Copy Resources (Handle SwiftPM bundle)
# SwiftPM creates a bundle named ${TargetName}_${TargetName}.bundle
BUNDLE_NAME="${APP_NAME}_${APP_NAME}.bundle"
if [ -d "${BUILD_DIR}/${BUNDLE_NAME}" ]; then
    echo "Copying resources bundle..."
    cp -r "${BUILD_DIR}/${BUNDLE_NAME}" "${APP_BUNDLE}/Contents/Resources/"
fi

# 5. Generate App Icon (ICNS)
if [ -f "${SOURCE_ICON}" ]; then
    echo "Generating AppIcon.icns..."
    ICONSET_DIR="AppIcon.iconset"
    mkdir -p "${ICONSET_DIR}"
    
    # Generate resized images
    sips -s format png -z 16 16     "${SOURCE_ICON}" --out "${ICONSET_DIR}/icon_16x16.png" > /dev/null
    sips -s format png -z 32 32     "${SOURCE_ICON}" --out "${ICONSET_DIR}/icon_16x16@2x.png" > /dev/null
    sips -s format png -z 32 32     "${SOURCE_ICON}" --out "${ICONSET_DIR}/icon_32x32.png" > /dev/null
    sips -s format png -z 64 64     "${SOURCE_ICON}" --out "${ICONSET_DIR}/icon_32x32@2x.png" > /dev/null
    sips -s format png -z 128 128   "${SOURCE_ICON}" --out "${ICONSET_DIR}/icon_128x128.png" > /dev/null
    sips -s format png -z 256 256   "${SOURCE_ICON}" --out "${ICONSET_DIR}/icon_128x128@2x.png" > /dev/null
    sips -s format png -z 256 256   "${SOURCE_ICON}" --out "${ICONSET_DIR}/icon_256x256.png" > /dev/null
    sips -s format png -z 512 512   "${SOURCE_ICON}" --out "${ICONSET_DIR}/icon_256x256@2x.png" > /dev/null
    sips -s format png -z 512 512   "${SOURCE_ICON}" --out "${ICONSET_DIR}/icon_512x512.png" > /dev/null
    sips -s format png -z 1024 1024 "${SOURCE_ICON}" --out "${ICONSET_DIR}/icon_512x512@2x.png" > /dev/null
    
    # Create icns
    iconutil -c icns "${ICONSET_DIR}" -o "${APP_BUNDLE}/Contents/Resources/AppIcon.icns"
    rm -rf "${ICONSET_DIR}"
fi

# 6. Create Info.plist
echo "Creating Info.plist..."
cat > "${APP_BUNDLE}/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>com.example.${APP_NAME}</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>LSUIElement</key>
    <false/>
</dict>
</plist>
EOF

echo "✅ App packaged successfully: ${APP_BUNDLE}"
