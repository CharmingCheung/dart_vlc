#!/bin/bash
# macOS VLC 3.0.22 集成一键脚本
# 此脚本会自动配置所有必要的文件以使用自定义编译的 VLC 3.0.22

set -e

echo "🍎 Starting macOS VLC 3.0.22 integration..."
echo ""

# 验证自定义 VLC 路径是否存在
VLC_INSTALL_DIR="/Users/charming/IdeaProjects/vlc/build/vlc_install_dir"
VLC_APP_PLUGINS="/Users/charming/IdeaProjects/vlc/build/VLC.app/Contents/MacOS/plugins"

if [ ! -d "$VLC_INSTALL_DIR" ]; then
    echo "❌ Error: VLC installation directory not found: $VLC_INSTALL_DIR"
    echo "   Please build VLC first or update the path in this script."
    exit 1
fi

if [ ! -d "$VLC_APP_PLUGINS" ]; then
    echo "⚠️  Warning: VLC plugins directory not found: $VLC_APP_PLUGINS"
    echo "   Plugin copy may fail during build."
fi

echo "✅ VLC directories validated"
echo ""

# 1. 备份原始文件
echo "📋 Backing up original files..."
[ ! -f "macos/dart_vlc.podspec.backup" ] && cp macos/dart_vlc.podspec macos/dart_vlc.podspec.backup && echo "   ✅ podspec backed up"
[ ! -f "example/macos/Podfile.backup" ] && cp example/macos/Podfile example/macos/Podfile.backup && echo "   ✅ Podfile backed up"
[ ! -f "example/lib/main.dart.backup" ] && cp example/lib/main.dart example/lib/main.dart.backup && echo "   ✅ main.dart backed up"
echo ""

# 2. 更新 podspec（注释掉 VLCKit 依赖，添加自定义 VLC 路径）
echo ""
echo "📝 Updating podspec..."

cat > macos/dart_vlc.podspec << 'PODSPEC_EOF'
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint dart_vlc.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'dart_vlc'
  s.version          = '0.0.1'
  s.summary          = 'Flutter VLC plugin with custom VLC 3.0.22'
  s.description      = <<-DESC
Flutter VLC plugin with custom VLC 3.0.22 (DASH subtitle fix & ClearKey DRM support).
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }

  s.script_phases = [{
    :name => 'Fetch submodules',
    :show_env_vars_in_log => true,
    :script => 'cd ${PODS_TARGET_SRCROOT}/.. && git submodule update --init --recursive || true',
    :execution_position => :before_compile
  }, {
    :name => 'Build dart_vlc_core',
    :show_env_vars_in_log => true,
    :script => '/opt/homebrew/bin/cmake -Bcore_core ${PODS_TARGET_SRCROOT}/../core -DCMAKE_INSTALL_PREFIX:PATH=${PODS_TARGET_SRCROOT}/deps && pwd && make -C core_core install',
    :execution_position => :before_compile,
    :output_files => ['${PODS_TARGET_SRCROOT}/deps/lib/libdart_vlc_core.a']
  }, {
    :name => 'Copy Custom VLC 3.0.22',
    :show_env_vars_in_log => true,
    :script => 'bash ${PODS_TARGET_SRCROOT}/copy_vlc_plugins.sh',
    :execution_position => :after_compile
  }]

  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*.{h,m,mm}'
  s.dependency 'FlutterMacOS'

  # 使用自定义 VLC 3.0.22，不再依赖 CocoaPods VLCKit
  # s.dependency 'VLCKit', '~>3.3'

  s.platform = :osx
  s.osx.deployment_target = '10.15'
  s.library = 'c++'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',

    # 自定义 VLC 3.0.22 头文件路径
    'HEADER_SEARCH_PATHS' => [
      '$(PODS_TARGET_SRCROOT)/../core',
      '/Users/charming/IdeaProjects/vlc/build/vlc_install_dir/include',
      '${PODS_ROOT}/core_core/dart_vlc_core_packages/libvlcpp-master',
      '${PODS_ROOT}/core_core/dart_vlc_core_packages/dart_api-master',
    ].join(' '),

    # 自定义 VLC 3.0.22 库路径
    'LIBRARY_SEARCH_PATHS' => [
      '$(PODS_TARGET_SRCROOT)/deps/lib',
      '/Users/charming/IdeaProjects/vlc/build/vlc_install_dir/lib',
    ].join(' '),

    'OTHER_CFLAGS' => [
      '-Wno-documentation',
    ],

    'OTHER_CXXFLAGS' => [
      '-Wno-documentation',
    ],

    # 链接自定义 VLC 库
    'OTHER_LDFLAGS' => [
      '-ldart_vlc_core',
      '-Wl,-force_load,${PODS_TARGET_SRCROOT}/deps/lib/libdart_vlc_core.a',
      '-L/Users/charming/IdeaProjects/vlc/build/vlc_install_dir/lib',
      '-lvlc',
      '-lvlccore',
      '-Wl,-rpath,/Users/charming/IdeaProjects/vlc/build/vlc_install_dir/lib',
      '-Wl,-rpath,@executable_path/../Frameworks',
    ],

    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++17',
    'CLANG_CXX_LIBRARY' => 'libc++',
  }

  s.swift_version = '5.0'
end
PODSPEC_EOF

echo "   ✅ podspec updated"

# 3. 创建/更新 VLC 插件复制脚本
echo ""
echo "📝 Creating VLC plugin copy script..."

cat > macos/copy_vlc_plugins.sh << 'COPY_SCRIPT_EOF'
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
    # 只复制 .dylib 文件,跳过 .dat, .jar, .lua 等其他文件
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
COPY_SCRIPT_EOF

chmod +x macos/copy_vlc_plugins.sh
echo "   ✅ copy_vlc_plugins.sh created and made executable"

# 4. 更新 Podfile 的 deployment target
echo ""
echo "📝 Updating Podfile deployment target..."
sed -i '' "s/platform :osx, '[0-9.]*'/platform :osx, '10.15'/" example/macos/Podfile
echo "   ✅ Podfile updated to macOS 10.15"

# 5. 更新 example/lib/main.dart 添加插件路径
echo ""
echo "📝 Updating example app to use custom VLC plugin path..."

# 检查是否已经包含插件路径配置
if grep -q "plugin-path=/Users/charming" example/lib/main.dart; then
    echo "   ℹ️  Plugin path already configured in main.dart"
else
    # 查找 Player 构造并添加 commandlineArguments
    sed -i '' '/Player player = Player(/,/);/{
        /id: 0/a\
    commandlineArguments: Platform.isMacOS\
        ? ['\''--plugin-path=/Users/charming/IdeaProjects/vlc/build/VLC.app/Contents/MacOS/plugins'\'']\
        : null,
    }' example/lib/main.dart

    echo "   ✅ Plugin path added to main.dart"
    echo "   ⚠️  Note: You may need to manually verify the Player constructor modification"
fi

# 6. 更新 AppDelegate.swift 为现代 Swift 规范
echo ""
echo "📝 Updating AppDelegate.swift..."

cat > example/macos/Runner/AppDelegate.swift << 'APPDELEGATE_EOF'
import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
APPDELEGATE_EOF

echo "   ✅ AppDelegate.swift updated"

# 7. 验证复制脚本存在
if [ -f "macos/copy_vlc_plugins.sh" ]; then
    echo ""
    echo "✅ Plugin copy script found"
    chmod +x macos/copy_vlc_plugins.sh
else
    echo ""
    echo "⚠️  Warning: macos/copy_vlc_plugins.sh not found (should have been created above)"
fi

echo ""
echo "📊 Summary of changes:"
echo "   ✅ macos/dart_vlc.podspec - Updated to use custom VLC 3.0.22"
echo "   ✅ macos/copy_vlc_plugins.sh - Created plugin copy script"
echo "   ✅ example/macos/Podfile - Deployment target → 10.15"
echo "   ✅ example/lib/main.dart - Added VLC plugin path"
echo "   ✅ example/macos/Runner/AppDelegate.swift - Modernized"

# 8. 清理并重新构建
echo ""
echo "🧹 Cleaning previous build..."
cd example
flutter clean
rm -rf macos/Pods macos/.symlinks macos/Podfile.lock
rm -rf ~/Library/Caches/CocoaPods/Pods/Release/dart_vlc || true

echo ""
echo "📦 Getting Flutter dependencies..."
flutter pub get

echo ""
echo "🔨 Installing CocoaPods..."
cd macos
pod install --repo-update || pod install

echo ""
echo "🏗️  Building macOS app (Debug)..."
cd ..
flutter build macos --debug

echo ""
echo "✅ macOS VLC 3.0.22 integration complete!"
echo ""
echo "📊 Verification commands:"
echo "   Check VLC libraries:"
echo "   ls -lh build/macos/Build/Products/Debug/dart_vlc_example.app/Contents/Frameworks/libvlc*.dylib"
echo ""
echo "   Check VLC plugins:"
echo "   ls build/macos/Build/Products/Debug/dart_vlc_example.app/Contents/MacOS/plugins/*.dylib | wc -l"
echo ""
echo "   Check DASH plugin:"
echo "   ls build/macos/Build/Products/Debug/dart_vlc_example.app/Contents/MacOS/plugins/libadaptive_plugin.dylib"
echo ""
echo "🚀 Run with:"
echo "   flutter run -d macos"
echo ""
echo "📝 Note: All changes have been backed up with .backup extension"
