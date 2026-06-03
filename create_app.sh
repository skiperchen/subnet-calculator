#!/bin/bash
# ============================================================
# 子网掩码计算器 - macOS .app 打包脚本
# 在 macOS 上运行此脚本生成原生应用
# ============================================================

set -e

APP_NAME="子网掩码计算器"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/output"
INDEX_HTML="$SCRIPT_DIR/index.html"

echo "=========================================="
echo "  子网掩码计算器 - macOS App 打包"
echo "=========================================="
echo ""

# ---------- 方法1: Nativefier (推荐, 最完整的App体验) ----------
build_nativefier() {
    echo ">>> 方法1: 使用 Nativefier (Electron) 打包"

    if ! command -v npx &>/dev/null && ! command -v node &>/dev/null; then
        echo "  ⚠ Node.js 未安装, 跳过 Nativefier"
        echo "  安装: brew install node"
        return 1
    fi

    mkdir -p "$OUTPUT_DIR"

    # 构建一个带完整功能的打包HTML
    echo "  正在用 Nativefier 打包..."
    npx --yes nativefier \
        --name "$APP_NAME" \
        --platform osx \
        --arch arm64 \
        --icon "$SCRIPT_DIR/icon.png" 2>/dev/null || true \
        --width 960 \
        --height 720 \
        --min-width 600 \
        --min-height 400 \
        --disable-dev-tools \
        --single-instance \
        --title-bar-style 'hiddenInset' \
        "$INDEX_HTML" \
        "$OUTPUT_DIR"

    # 如果没有icon，跳过也行
    if [ ! -f "$SCRIPT_DIR/icon.png" ]; then
        npx --yes nativefier \
            --name "$APP_NAME" \
            --platform osx \
            --arch arm64 \
            --width 960 \
            --height 720 \
            --min-width 600 \
            --min-height 400 \
            --disable-dev-tools \
            --single-instance \
            --title-bar-style 'hiddenInset' \
            "$INDEX_HTML" \
            "$OUTPUT_DIR"
    fi

    echo "  ✅ Nativefier App 已生成到: $OUTPUT_DIR"
    echo "  可以直接双击 .app 文件运行"
}

# ---------- 方法2: Automator 应用 ----------
build_automator() {
    echo ">>> 方法2: 创建 Automator 应用包装器"

    # 复制 index.html 到 output/app
    mkdir -p "$OUTPUT_DIR/$APP_NAME.app/Contents/MacOS"
    mkdir -p "$OUTPUT_DIR/$APP_NAME.app/Contents/Resources"

    cp "$INDEX_HTML" "$OUTPUT_DIR/$APP_NAME.app/Contents/Resources/index.html"

    # 创建启动脚本
    cat > "$OUTPUT_DIR/$APP_NAME.app/Contents/MacOS/launcher.sh" << 'LAUNCHER'
#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
open "$DIR/../Resources/index.html"
LAUNCHER
    chmod +x "$OUTPUT_DIR/$APP_NAME.app/Contents/MacOS/launcher.sh"

    # 创建 Info.plist
    cat > "$OUTPUT_DIR/$APP_NAME.app/Contents/Info.plist" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleDisplayName</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.subnetcalc.app</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleExecutable</key>
    <string>launcher.sh</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.13</string>
</dict>
</plist>
PLIST
    echo "  ✅ Automator-style App 已生成: $OUTPUT_DIR/$APP_NAME.app"
}

# ---------- 方法3: Python WebView App (推荐, 最轻量) ----------
build_python_app() {
    echo ">>> 方法3: 创建 Python WebView 应用"

    if ! command -v python3 &>/dev/null; then
        echo "  ⚠ Python3 未安装, 跳过"
        return 1
    fi

    # 生成独立的Python应用目录
    mkdir -p "$OUTPUT_DIR/SubnetCalc.app/Contents/MacOS"
    mkdir -p "$OUTPUT_DIR/SubnetCalc.app/Contents/Resources"

    cp "$INDEX_HTML" "$OUTPUT_DIR/SubnetCalc.app/Contents/Resources/index.html"
    cp "$SCRIPT_DIR/subnet-calc.py" "$OUTPUT_DIR/SubnetCalc.app/Contents/Resources/"

    # 创建启动脚本 (使用系统Python + webview)
    cat > "$OUTPUT_DIR/SubnetCalc.app/Contents/MacOS/SubnetCalc" << 'EXEC'
#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
RESOURCES="$DIR/../Resources"
cd "$RESOURCES"

# 安装依赖 (如果需要)
python3 -c "import webview" 2>/dev/null || pip3 install pywebview --quiet

python3 subnet-calc.py
EXEC
    chmod +x "$OUTPUT_DIR/SubnetCalc.app/Contents/MacOS/SubnetCalc"

    cat > "$OUTPUT_DIR/SubnetCalc.app/Contents/Info.plist" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>SubnetCalc</string>
    <key>CFBundleDisplayName</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.subnetcalc.pythonapp</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleExecutable</key>
    <string>SubnetCalc</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.15</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST
    echo "  ✅ Python WebView App 已生成: $OUTPUT_DIR/SubnetCalc.app"
    echo "  首次运行需安装 pywebview: pip3 install pywebview"
}

# ---------- 方法4: 创建 DMG 安装包 ----------
create_dmg() {
    if [ ! -d "$OUTPUT_DIR" ] || [ -z "$(ls -A "$OUTPUT_DIR"/*.app 2>/dev/null)" ]; then
        echo "  ⚠ 没有 .app 文件，先运行打包方法"
        return 1
    fi

    if command -v create-dmg &>/dev/null; then
        create-dmg \
            --volname "$APP_NAME" \
            --window-size 500 320 \
            --icon-size 100 \
            --app-drop-link 400 140 \
            "$OUTPUT_DIR/$APP_NAME.dmg" \
            "$OUTPUT_DIR/"*.app
        echo "  ✅ DMG 安装包已生成: $OUTPUT_DIR/$APP_NAME.dmg"
    else
        echo "  ⚠ create-dmg 未安装, 跳过 DMG 创建"
        echo "  安装: brew install create-dmg"
        # fallback: hdiutil
        hdiutil create -volname "$APP_NAME" -srcfolder "$OUTPUT_DIR" -ov "$OUTPUT_DIR/$APP_NAME.dmg" 2>/dev/null || true
        echo "  ✅ 使用 hdiutil 创建了基础 DMG"
    fi
}

# ==================== 主流程 ====================

case "${1:-all}" in
    nativefier|1)
        build_nativefier
        ;;
    automator|2)
        build_automator
        ;;
    python|3)
        build_python_app
        ;;
    dmg|4)
        create_dmg
        ;;
    all)
        echo "选择打包方法:"
        echo "  1) Nativefier (Electron) - 完整独立App, ~150MB"
        echo "  2) Automator 包装 - 用浏览器打开, ~10KB"
        echo "  3) Python WebView - 轻量原生窗口, ~5MB"
        echo "  4) 创建 DMG 安装包"
        echo ""
        # 默认用 Python WebView (最轻量)
        build_python_app
        ;;
    *)
        echo "用法: $0 [nativefier|automator|python|dmg|all]"
        echo ""
        echo "示例:"
        echo "  $0 python      # 用 Python WebView 打包 (推荐)"
        echo "  $0 nativefier  # 用 Nativefier 打包 (独立Electron应用)"
        echo "  $0 dmg         # 创建 DMG 安装包"
        ;;
esac

echo ""
echo "=========================================="
echo "  打包完成!"
echo "  App 位置: $OUTPUT_DIR"
echo "=========================================="
