# Note on updating Cocoapods:
# - Running 'pod install' will create a new Podfile.lock, which will create a "snapshot" of all Pods at that time.
# - Running 'pod update' will use the values in Podfile.lock.
# - IMPORTANT: Unless you need to update Cocoapods for this project, use 'pod update' to maintain a stable build.

# Minimum iOS version.
platform :ios, '13.0'
# Use dynamic frameworks.
use_frameworks!

# Pods that should be included in all apps.
def core_pods
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Analytics'
  pod 'SBPickerSelector', '1.0.4' # Last Objc version.
  pod 'CorePlot' # https://github.com/core-plot/core-plot
  pod 'FMDB' # https://github.com/ccgus/fmdb
  pod 'FSCalendar' # https://github.com/WenchaoD/FSCalendar
  pod 'MBProgressHUD' # https://github.com/matej/MBProgressHUD
  pod 'MKNumberBadgeView' # https://github.com/erichoracek/MKNumberBadgeView
  
  # To be deprecated:
  pod 'ASIHTTPRequest' # https://cocoapods.org/pods/ASIHTTPRequest
  pod 'ZipArchive' # https://github.com/mattconnolly/ZipArchive
end

target 'DietMasterGoPlus' do
  core_pods
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
