#
# Be sure to run `pod lib lint Daysquare.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Daysquare'
  s.version          = '0.1.0'
  s.summary          = 'An elegant calendar control for iOS.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Get bored with native silly UIDatePicker? You may have a try on this control. Instead of showing you an awkward wheel, it just presents as a intuitive full-size calendar with a lot of preference properties that you can change.
                       DESC

  s.homepage         = 'https://github.com/unixzii/Daysquare'
  s.screenshots     = 'https://github.com/unixzii/Daysquare/raw/master/Images/overview.gif'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Cyandev' => 'unixzii@gmail.com' }
  s.source           = { :git => 'https://github.com/unixzii/Daysquare.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'Pod/Classes/**/*'

  s.resource_bundles = {
    'Daysquare' => ['Daysquare/Assets/*.png']
  }

  s.public_header_files = 'Pod/Classes/Daysquare.h'
  s.frameworks = 'UIKit'
end
