# Uncomment the next line to define a global platform for your project
  platform :ios, '13.0'

target 'DietMasterGoPlus' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for DietMasterGoPlus
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Analytics'
  pod 'SBPickerSelector', '1.0.4' # Last Objc version.
end

# Ensure all dependencies are a minimum version of iOS 13.
post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
               end
          end
   end
end
