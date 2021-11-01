# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

target 'ChatAppWithFirebase' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ChatAppWithFirebase
  pod 'Firebase/Analytics'
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Storage'
  pod 'Nuke'
  pod 'PKHUD'
  
  # 追加機能
  pod 'Firebase/MLNaturalLanguage', '6.25.0'
  pod 'Firebase/MLNLLanguageID', '6.25.0'
  pod 'Firebase/MLNLTranslate', '6.25.0'
  pod 'Firebase/MLCommon', '6.25.0'
  pod 'Firebase/MLNLSmartReply', '6.25.0'

  target 'ChatAppWithFirebaseTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'ChatAppWithFirebaseUITests' do
    # Pods for testing
  end

end

# iOSシミュレータでのarm64を除外
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
    end
  end
end
