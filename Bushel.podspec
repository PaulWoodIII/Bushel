#
# Be sure to run `pod lib lint Bushel.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Bushel"
  s.version          = "0.0.1"
  s.summary          = "an opinionated UICollectionView framework"
  s.description      = <<-DESC
					   Bushel is an iOS Collection View Framework forked from Apple's Collection View framework release at WWDC 2014. It is opinionated & constraining, which is just what you need to have something that is reliable.

					   Bushel is still under development and will be used in a future iOS app.
                       DESC
  s.homepage         = "https://github.com/paulwoodiii/Bushel"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "paulwoodiii" => "paul@paulwoodiii.com" }
  s.source           = { :git => "https://github.com/paulwoodiii/Bushel.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/paulwoodiii'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.resource_bundles = {
    'Bushel' => ['Pod/Assets/*.png']
  }
  s.frameworks = 'UIKit'
end
