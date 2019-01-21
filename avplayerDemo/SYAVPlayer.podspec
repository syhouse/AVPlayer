#
#  Be sure to run `pod spec lint SYAVPlayer.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

AVFoundation
  s.name         = "RXDStandard"
  s.version      = "0.0.1"
  s.summary      = "A short description of RXDStandard."

  s.homepage     = "https://github.com/syhouse/RXDStandard"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "syhouse" => "shiyaohouse@163.com" }

  s.source       = { :git => "https://github.com/syhouse/RXDStandard.git", :tag => "#{s.version}" }

  s.source_files  = "RXDStandard/*.{h,m}"
  s.requires_arc = true # 是否启用ARC
  s.platform     = :ios, "7.0" #平台及支持的最低版本
  s.frameworks   = "UIKit", "Foundation" #支持的框架
end
