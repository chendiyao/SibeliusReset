#!/bin/bash
set -euo pipefail

# Configuration
APP_NAME="Sibelius重置"
OUTPUT_DIR="build"
APP_BUNDLE="$OUTPUT_DIR/$APP_NAME.app"
MACOS_DIR="$APP_BUNDLE/Contents/MacOS"
RESOURCES_DIR="$APP_BUNDLE/Contents/Resources"
PLIST_FILE="$APP_BUNDLE/Contents/Info.plist"
LOGO_SOURCE="Assets/AppLogo.png"
LOGO_TRANSPARENT="Assets/AppLogoTransparent.png"
ICONSET_DIR="$OUTPUT_DIR/AppIcon.iconset"
TEMP_BUILD_DIR="$OUTPUT_DIR/BuildProducts"

# Clean up
echo "Cleaning up..."
rm -rf "$OUTPUT_DIR"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"
mkdir -p "$RESOURCES_DIR/zh-Hans.lproj"
mkdir -p "$TEMP_BUILD_DIR"

if [ ! -f "$LOGO_SOURCE" ]; then
    echo "Missing logo source: $LOGO_SOURCE"
    exit 1
fi

echo "Preparing transparent logo..."
if python3 -c "import PIL" >/dev/null 2>&1; then
    python3 scripts/remove_icon_background.py "$LOGO_SOURCE" "$LOGO_TRANSPARENT"
elif [ -f "$LOGO_TRANSPARENT" ]; then
    echo "Pillow is not available; using existing transparent logo: $LOGO_TRANSPARENT"
else
    echo "Pillow is required to create $LOGO_TRANSPARENT from $LOGO_SOURCE"
    exit 1
fi

echo "Generating app icon..."
mkdir -p "$ICONSET_DIR"
sips -z 16 16 "$LOGO_TRANSPARENT" --out "$ICONSET_DIR/icon_16x16.png" >/dev/null
sips -z 32 32 "$LOGO_TRANSPARENT" --out "$ICONSET_DIR/icon_16x16@2x.png" >/dev/null
sips -z 32 32 "$LOGO_TRANSPARENT" --out "$ICONSET_DIR/icon_32x32.png" >/dev/null
sips -z 64 64 "$LOGO_TRANSPARENT" --out "$ICONSET_DIR/icon_32x32@2x.png" >/dev/null
sips -z 128 128 "$LOGO_TRANSPARENT" --out "$ICONSET_DIR/icon_128x128.png" >/dev/null
sips -z 256 256 "$LOGO_TRANSPARENT" --out "$ICONSET_DIR/icon_128x128@2x.png" >/dev/null
sips -z 256 256 "$LOGO_TRANSPARENT" --out "$ICONSET_DIR/icon_256x256.png" >/dev/null
sips -z 512 512 "$LOGO_TRANSPARENT" --out "$ICONSET_DIR/icon_256x256@2x.png" >/dev/null
sips -z 512 512 "$LOGO_TRANSPARENT" --out "$ICONSET_DIR/icon_512x512.png" >/dev/null
sips -z 1024 1024 "$LOGO_TRANSPARENT" --out "$ICONSET_DIR/icon_512x512@2x.png" >/dev/null
iconutil -c icns "$ICONSET_DIR" -o "$RESOURCES_DIR/AppIcon.icns"

# Compile Swift code
SDK_PATH="$(xcrun --show-sdk-path --sdk macosx)"
SOURCE_FILES=(Sources/*.swift Sources/Views/*.swift)
ARM_BINARY="$TEMP_BUILD_DIR/$APP_NAME-arm64"
X86_BINARY="$TEMP_BUILD_DIR/$APP_NAME-x86_64"

compile_arch() {
    local arch_name="$1"
    local target_triple="$2"
    local output_path="$3"

    echo "Compiling Swift files for $arch_name..."
    swiftc \
        -target "$target_triple" \
        -sdk "$SDK_PATH" \
        -framework SwiftUI -framework AppKit -framework Foundation \
        -parse-as-library \
        "${SOURCE_FILES[@]}" \
        -o "$output_path"
}

compile_arch "arm64" "arm64-apple-macosx12.0" "$ARM_BINARY"
compile_arch "x86_64" "x86_64-apple-macosx12.0" "$X86_BINARY"

echo "Creating universal binary..."
lipo -create "$ARM_BINARY" "$X86_BINARY" -output "$MACOS_DIR/$APP_NAME"
chmod +x "$MACOS_DIR/$APP_NAME"
lipo -info "$MACOS_DIR/$APP_NAME"

# Create Info.plist
echo "Creating Info.plist..."
cat > "$PLIST_FILE" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.futuristic.sibeliusreset</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleDisplayName</key>
    <string>$APP_NAME</string>
    <key>CFBundleDevelopmentRegion</key>
    <string>zh-Hans</string>
    <key>CFBundleLocalizations</key>
    <array>
        <string>zh-Hans</string>
    </array>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

cat > "$RESOURCES_DIR/zh-Hans.lproj/InfoPlist.strings" << EOF
CFBundleName = "$APP_NAME";
CFBundleDisplayName = "$APP_NAME";
EOF

echo "Applying ad-hoc code signature..."
codesign --force --deep --sign - "$APP_BUNDLE"
codesign --verify --deep --strict "$APP_BUNDLE"

echo "Done! The application is located at $APP_BUNDLE"
