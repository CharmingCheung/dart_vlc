#!/bin/bash
# 将自定义 VLC 3.0.22 插件和库复制到 app bundle

# Don't exit on errors - we'll handle them individually
set +e

# 源路径
VLC_PLUGINS_SRC="/Users/charming/IdeaProjects/vlc/build/VLC.app/Contents/MacOS/plugins"
VLC_LIB_SRC="/Users/charming/IdeaProjects/vlc/build/vlc_install_dir/lib"

# 目标路径
APP_BUNDLE="$BUILT_PRODUCTS_DIR/$PRODUCT_NAME.app"
# On macOS, VLC looks for plugins in ../MacOS/plugins relative to Frameworks
# Or we can set it via VLC_PLUGIN_PATH environment variable
VLC_PLUGINS_DEST="$APP_BUNDLE/Contents/MacOS/plugins"
VLC_LIB_DEST="$APP_BUNDLE/Contents/Frameworks"

echo "📦 Copying custom VLC 3.0.22 plugins and libraries..."
echo "   Source plugins: $VLC_PLUGINS_SRC"
echo "   Source libs:    $VLC_LIB_SRC"
echo "   App bundle:     $APP_BUNDLE"

# 复制插件 (仅 .dylib 文件以避免代码签名问题)
if [ -d "$VLC_PLUGINS_SRC" ]; then
    echo "   📁 Copying VLC plugins (.dylib files only)..."
    mkdir -p "$VLC_PLUGINS_DEST"
    # 只复制 .dylib 文件，跳过 .dat, .jar, .lua 等其他文件
    find "$VLC_PLUGINS_SRC" -name "*.dylib" -exec cp {} "$VLC_PLUGINS_DEST/" \; 2>/dev/null || echo "⚠️  Warning: Plugin copy failed"
    PLUGIN_COUNT=$(find "$VLC_PLUGINS_DEST" -name "*.dylib" 2>/dev/null | wc -l)
    echo "   ✅ Copied $PLUGIN_COUNT plugin files"
else
    echo "   ⚠️  Warning: Plugin source not found: $VLC_PLUGINS_SRC"
fi

# 复制 VLC 库
if [ -f "$VLC_LIB_SRC/libvlc.5.dylib" ]; then
    echo "   📚 Copying VLC libraries..."
    cp "$VLC_LIB_SRC/libvlc.5.dylib" "$VLC_LIB_DEST/" || echo "⚠️  Warning: libvlc copy failed"
    cp "$VLC_LIB_SRC/libvlccore.9.dylib" "$VLC_LIB_DEST/" || echo "⚠️  Warning: libvlccore copy failed"

    # 创建符号链接
    cd "$VLC_LIB_DEST"
    ln -sf libvlc.5.dylib libvlc.dylib 2>/dev/null || true
    ln -sf libvlccore.9.dylib libvlccore.dylib 2>/dev/null || true

    echo "   ✅ VLC libraries copied"
else
    echo "   ⚠️  Warning: VLC libraries not found: $VLC_LIB_SRC"
fi

# 验证
if [ -f "$VLC_PLUGINS_DEST/libadaptive_plugin.dylib" ]; then
    echo "   ✅ DASH plugin found (libadaptive_plugin.dylib)"
else
    echo "   ⚠️  Warning: DASH plugin not found"
fi

echo "✅ VLC 3.0.22 integration complete!"
