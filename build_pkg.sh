#!/bin/bash
set -euo pipefail

APP_NAME="Sibelius重置"
APP_IDENTIFIER="com.futuristic.sibeliusreset"
PKG_IDENTIFIER="$APP_IDENTIFIER.pkg"
VERSION="1.0"

BUILD_DIR="build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
PKG_WORK_DIR="$BUILD_DIR/pkg-work"
PKG_ROOT="$PKG_WORK_DIR/root"
PKG_SCRIPTS="$PKG_WORK_DIR/scripts"
PKG_OUTPUT="$BUILD_DIR/$APP_NAME-$VERSION-universal.pkg"

echo "Building universal app..."
./build.sh

if [ ! -d "$APP_BUNDLE" ]; then
    echo "Missing app bundle: $APP_BUNDLE"
    exit 1
fi

echo "Preparing package root..."
rm -rf "$PKG_WORK_DIR"
rm -f "$PKG_OUTPUT"
mkdir -p "$PKG_ROOT/Applications"
mkdir -p "$PKG_SCRIPTS"

/usr/bin/ditto "$APP_BUNDLE" "$PKG_ROOT/Applications/$APP_NAME.app"

cat > "$PKG_SCRIPTS/postinstall" <<'EOF'
#!/bin/bash
set -euo pipefail

APP_PATH="/Applications/Sibelius重置.app"

if [ -d "$APP_PATH" ]; then
    /usr/bin/xattr -dr com.apple.quarantine "$APP_PATH" 2>/dev/null || true
    /usr/sbin/chown -R root:wheel "$APP_PATH" 2>/dev/null || true
    /bin/chmod -R a+rX "$APP_PATH" 2>/dev/null || true
fi

exit 0
EOF

chmod 755 "$PKG_SCRIPTS/postinstall"

echo "Building pkg..."
/usr/bin/pkgbuild \
    --root "$PKG_ROOT" \
    --scripts "$PKG_SCRIPTS" \
    --identifier "$PKG_IDENTIFIER" \
    --version "$VERSION" \
    --install-location "/" \
    --ownership recommended \
    "$PKG_OUTPUT"

echo "Verifying pkg payload..."
/usr/sbin/pkgutil --payload-files "$PKG_OUTPUT" >/dev/null

echo "Done! The installer package is located at $PKG_OUTPUT"
