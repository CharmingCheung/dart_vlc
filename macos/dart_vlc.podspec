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
  s.preserve_paths   = 'deps/lib/libdart_vlc_core.a'
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
