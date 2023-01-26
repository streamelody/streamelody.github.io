cask 'java8' do
  version '1.8.0_202-b08'
  sha256 'b41367948cf99ca0b8d1571f116b7e3e322dd1ebdfd4d390e959164d75b97c20'

  java_update = version.sub(%r{.*_(\d+)-.*}, '\1')
  url "https://repo.huaweicloud.com/java/jdk/8u202-b08/jdk-8u202-macosx-x64.dmg"
  name 'Java Standard Edition Development Kit'
  homepage "https://www.oracle.com/technetwork/java/javase/downloads/jdk#{version.minor}-downloads-2133151.html"

  pkg "JDK #{version.minor} Update #{java_update}.pkg"

  postflight do
    system_command '/usr/libexec/PlistBuddy',
                   args: ['-c', 'Add :JavaVM:JVMCapabilities: string BundledApp', "/Library/Java/JavaVirtualMachines/jdk#{version.split('-')[0]}.jdk/Contents/Info.plist"],
                   sudo: true
    system_command '/usr/libexec/PlistBuddy',
                   args: ['-c', 'Add :JavaVM:JVMCapabilities: string JNI', "/Library/Java/JavaVirtualMachines/jdk#{version.split('-')[0]}.jdk/Contents/Info.plist"],
                   sudo: true
    system_command '/usr/libexec/PlistBuddy',
                   args: ['-c', 'Add :JavaVM:JVMCapabilities: string WebStart', "/Library/Java/JavaVirtualMachines/jdk#{version.split('-')[0]}.jdk/Contents/Info.plist"],
                   sudo: true
    system_command '/usr/libexec/PlistBuddy',
                   args: ['-c', 'Add :JavaVM:JVMCapabilities: string Applets', "/Library/Java/JavaVirtualMachines/jdk#{version.split('-')[0]}.jdk/Contents/Info.plist"],
                   sudo: true
    system_command '/bin/ln',
                   args: ['-nsf', '--', "/Library/Java/JavaVirtualMachines/jdk#{version.split('-')[0]}.jdk/Contents/Home", '/Library/Java/Home'],
                   sudo: true
    system_command '/bin/mkdir',
                   args: ['-p', '--', "/Library/Java/JavaVirtualMachines/jdk#{version.split('-')[0]}.jdk/Contents/Home/bundle/Libraries"],
                   sudo: true
    system_command '/bin/ln',
                   args: ['-nsf', '--', "/Library/Java/JavaVirtualMachines/jdk#{version.split('-')[0]}.jdk/Contents/Home/jre/lib/server/libjvm.dylib", "/Library/Java/JavaVirtualMachines/jdk#{version.split('-')[0]}.jdk/Contents/Home/bundle/Libraries/libserver.dylib"],
                   sudo: true

    if MacOS.version <= :mavericks
      system_command '/bin/rm',
                     args: ['-rf', '--', '/System/Library/Frameworks/JavaVM.framework/Versions/CurrentJDK'],
                     sudo: true
      system_command '/bin/ln',
                     args: ['-nsf', '--', "/Library/Java/JavaVirtualMachines/jdk#{version.split('-')[0]}.jdk/Contents", '/System/Library/Frameworks/JavaVM.framework/Versions/CurrentJDK'],
                     sudo: true
    end
  end

  uninstall pkgutil:   [
                         "com.oracle.jdk#{version.minor}u#{java_update}",
                         'com.oracle.jre',
                       ],
            launchctl: [
                         'com.oracle.java.Helper-Tool',
                         'com.oracle.java.Java-Updater',
                       ],
            quit:      [
                         'com.oracle.java.Java-Updater',
                         'net.java.openjdk.cmd', # Java Control Panel
                       ],
            delete:    [
                         '/Library/Internet Plug-Ins/JavaAppletPlugin.plugin',
                         "/Library/Java/JavaVirtualMachines/jdk#{version.split('-')[0]}.jdk/Contents",
                         '/Library/PreferencePanes/JavaControlPanel.prefPane',
                         '/Library/Java/Home',
                         if MacOS.version <= :mavericks
                           [
                             '/usr/lib/java/libjdns_sd.jnilib',
                             '/System/Library/Frameworks/JavaVM.framework/Versions/CurrentJDK',
                           ]
                         end,
                       ].keep_if { |v| !v.nil? }

  zap       delete: [
                      '~/Library/Application Support/Java/',
                      '~/Library/Application Support/Oracle/Java',
                      '~/Library/Caches/com.oracle.java.Java-Updater',
                      '~/Library/Caches/Oracle.MacJREInstaller',
                      '~/Library/Caches/net.java.openjdk.cmd',
                      '~/Library/Preferences/com.oracle.java.Java-Updater.plist',
                      '~/Library/Preferences/com.oracle.java.JavaAppletPlugin.plist',
                      '~/Library/Preferences/com.oracle.javadeployment.plist',
                    ],
            rmdir:  '~/Library/Application Support/Oracle/'

end
