platform :ios, '7.0'
inhibit_all_warnings!

link_with 'MineStatus', 'MineStatusTests'

pod 'CrashlyticsFramework', '~> 2.1'
pod 'DNSKit', '= 0.0.1'
pod 'CocoaAsyncSocket', '~> 7.3'
pod 'CocoaLumberjack', '~> 1.8'

post_install do |installer|

	# enable building all architectures all the time
	installer.project.build_configurations.each do |config|
		config.build_settings.delete 'ONLY_ACTIVE_ARCH'
	end

	# copy the acknowledgements to the settings bundle
	require 'fileutils'
	FileUtils.cp_r('Pods/Pods-acknowledgements.plist', 'MineStatus/Settings.bundle/Acknowledgements.plist', remove_destination: true)

end
