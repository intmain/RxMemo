platform :ios, '10.0'
use_frameworks!

target 'Memo' do
  pod 'RxSwift',    '3.0.0-rc.1'
  pod 'RxCocoa',    '3.0.0-rc.1'
  pod 'RxDataSources', '~> 1.0.0-rc.1'
#  pod 'Realm', git: 'https://github.com/realm/realm-cocoa.git', branch: 'master', :submodules => true
#  pod 'RealmSwift', :git => 'https://github.com/realm/realm-cocoa.git', :branch => 'master', :submodules => true
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
