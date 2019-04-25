---
title: Mac 下 Flutter 开发环境搭建
date: 2019/01/12 15:28:44
categories: 
- 编程
- 博客
tags: 
- mac
- Flutter
---

#  安装 Flutter SDK
① 下载 [Flutter SDK](https://flutter.dev/docs/development/tools/sdk/releases?tab=macos#macos) 并解压。

② 移动到`Home`下，并设置环境变量。

```shell
mv flutter/ ~
vim ~/.bash_profile
export PATH="~/flutter/bin:$PATH"
source ~/.bash_profile
```

# 安装 Dart SDK

```shell
brew tap dart-lang/dart
brew install dart
brew info dart
# 可以得到 Dart SDK 的路径
==> Caveats
Please note the path to the Dart SDK:
  /usr/local/opt/dart/libexec
```

<!--more-->

# 配置 Android 开发环境

① 下载 [Android Studio](https://developer.android.com/studio/index.html) 并安装。

② 打开`Android Studio`，挂上代理，确保`Downloading Components`顺利完成。

![](https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2019/mac_flutter/flutter_studio_downloading_components_001.png)

③ 安装`Flutter`插件。

![](https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2019/mac_flutter/flutter_studio_plugin.png)

④ 同意`Android licenses`。

```
flutter doctor --android-licenses
```

⑤ 根据需要安装`JDK`。

```shell
# 安装最新版
brew cask install java
# 或者安装 JDK 8
brew tap caskroom/versions
brew cask install java8
```

# 配置 iOS 开发环境

① App Store 中下载`Xcode`并安装。

② 下载并安装 [Command Line Tools (macOS 10.14) for Xcode 10.2](https://developer.apple.com/download/more/)。

③ `flutter doctor`出现以下提示。

```shell
[✗] iOS toolchain - develop for iOS devices
    ✗ Xcode installation is incomplete; a full installation is necessary for iOS
      development.
      Download at: https://developer.apple.com/xcode/download/
      Or install Xcode via the App Store.
      Once installed, run:
        sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
    ✗ libimobiledevice and ideviceinstaller are not installed. To install with
      Brew, run:
        brew update
        brew install --HEAD usbmuxd
        brew link usbmuxd
        brew install --HEAD libimobiledevice
        brew install ideviceinstaller
    ✗ ios-deploy not installed. To install:
        brew install ios-deploy
    ✗ CocoaPods not installed.
        CocoaPods is used to retrieve the iOS platform side's plugin code that
        responds to your plugin usage on the Dart side.
        Without resolving iOS dependencies with CocoaPods, plugins will not work
        on iOS.
        For more info, see https://flutter.io/platform-plugins
      To install:
        brew install cocoapods
        pod setup
```

④ 依次解决。

```shell
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
brew update
brew install --HEAD usbmuxd
brew link usbmuxd
brew install --HEAD libimobiledevice
brew install ideviceinstaller
brew install ios-deploy
brew install cocoapods
pod setup
```

# 使用 IntelliJ IDEA 创建 Flutter 项目

① 安装`Flutter`插件。

② 创建一个 Flutter 项目。

![](https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2019/mac_flutter/mac_flutter_004.png)

③ 设置 Dart SDK 的路径。

```shell
/flutter/bin/cache/dart-sdk
```

![](https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2019/mac_flutter/mac_flutter_003.png)

# 参考资料

1. [入门: 在macOS上搭建Flutter开发环境](https://flutterchina.club/setup-macos/)
2. [mac 上配置flutter开发环境](https://www.jianshu.com/p/eb782589be82)



