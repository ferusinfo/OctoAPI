#
#  Be sure to run `pod spec lint OctoAPI.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "OctoAPI"
  s.version      = "0.3.0"
  s.summary      = "Octo is a JSON API abstraction layer built on top of Alamofire for your iOS projects written in Swift 3"
  s.homepage     = "http://ferus.info"
  s.license      = "MIT"

  s.author             = { "Maciej Kołek" => "hello@ferus.info" }
  s.social_media_url   = "http://twitter.com/ferusinfo"
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/ferusinfo/OctoAPI.git", :tag => "#{s.version}" }

  s.source_files  = "Sources/*/*"
  s.dependency 'Alamofire', '~> 4.0'
  s.dependency 'Gloss', '~> 1.1'
  s.dependency 'HTMLString', '~> 1.0.2'
  s.dependency 'KeychainAccess', '~> 3.0.1'
end
