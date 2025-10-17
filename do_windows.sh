cd /Users/charming/IdeaProjects/vlc_private/build-win-x86_64/win64

# 创建压缩包
zip -r vlc-3.0.22.zip vlc-3.0.22/

# 复制到 dart_vlc
cp vlc-3.0.22.zip /Users/charming/IdeaProjects/dart_vlc/bin/

# 更新配置
cd /Users/charming/IdeaProjects/dart_vlc
sed -i.bak 's/LIBVLC_VERSION "3.0.21"/LIBVLC_VERSION "3.0.22"/' core/CMakeLists.txt

# 验证修改
grep LIBVLC_VERSION core/CMakeLists.txt

echo "✅ Windows VLC 集成完成！"