platform :ios, '10.0'

inhibit_all_warnings!

source 'http://git.flowever.net/component/Specs.git'
source 'https://github.com/CocoaPods/Specs.git'

install! 'cocoapods', generate_multiple_pod_projects: true

target 'GrabCut' do
  use_frameworks!
  
  pod 'AdLib'
  pod 'Toolkit', '~> 5.2.19'
  
  pod 'SnapKit', '4.2.0'
  
  pod 'SwiftGen'
  
  pod 'UMCCommon'
  pod 'UMCAnalytics'
  
  pod 'ToolCollection'
  
  pod 'EachNavigationBar'
  
  pod 'ApplyStyleKit'
  
  pod 'QMUIKit'
  
  pod 'KakaJSON', '~> 1.1.0'
  
  pod 'Permission/Photos'
  
  pod 'TZImagePickerController'
end

#post_install do |installer|
#  installer.pod_target_subprojects.flat_map { |p| p.targets }.each do |target|
#    target.build_configurations.each do |config|
#      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
#    end
#  end
#end
