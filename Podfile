# Note on updating Cocoapods:
# - Running 'pod install' will create a new Podfile.lock, which will create a "snapshot" of all Pods at that time.
# - Running 'pod update' will use the values in Podfile.lock.
# - IMPORTANT: Unless you need to update Cocoapods for this project, use 'pod update' to maintain a stable build.

# Minimum iOS version. Note: This project should have N-2 support.
platform :ios, '15.0'
# Use dynamic frameworks.
use_frameworks!

# Pods that should be included in all apps.
def core_pods
  pod 'AlamofireSoap' # https://github.com/ShakeebM/AlamofireSoap
  pod 'SWXMLHash' # For decoding XML in Alamofire responses - https://github.com/drmohundro/SWXMLHash

  pod 'Firebase/Crashlytics'
  pod 'Firebase/Analytics'
  pod 'SBPickerSelector', '1.0.4' # Last Objc version.
  pod 'CorePlot' # https://github.com/core-plot/core-plot
  pod 'FMDB' # https://github.com/ccgus/fmdb
  pod 'FSCalendar' # https://github.com/WenchaoD/FSCalendar
  pod 'MBProgressHUD' # https://github.com/matej/MBProgressHUD
  pod 'MKNumberBadgeView' # https://github.com/erichoracek/MKNumberBadgeView
  pod 'JJFloatingActionButton' # https://github.com/jjochen/JJFloatingActionButton
  pod 'TTTAttributedLabel' # https://github.com/TTTAttributedLabel/TTTAttributedLabel
  # Note: See GrowingTextView.swift in the project for details why this is commented out.
  #pod 'GrowingTextView' # https://github.com/KennethTsang/GrowingTextView
  
  # Note, this pod is archived as of 2021, but should last 2 years before needing replacement.
  pod 'ScrollableSegmentedControl' # https://github.com/GocePetrovski/ScrollableSegmentedControl

  # To be deprecated:
  pod 'ASIHTTPRequest' # https://cocoapods.org/pods/ASIHTTPRequest
end

# Replica Base Demo.
target 'ReplicaTemplate' do
  core_pods
end

target 'DietMasterGo' do
  core_pods
end

target 'DietMasterGoPlus' do
  core_pods
end

target 'JLNutrition' do
  core_pods
end

# Ensure all dependencies are a minimum version of iOS 15.
post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
               end
          end
   end
end
