#
# Be sure to run `pod lib lint LSPhotoSelect.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LSPhotoSelect'
  s.version          = '0.1.0'
  s.summary          = '本地图片选择浏览'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
本地图片选择浏览 0.1.0
                       DESC

  s.homepage         = 'https://github.com/Lius1104'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Lius' => '15093319898@163.com' }
  s.source           = { :git => 'https://github.com/Lius1104/LSPhotoSelect.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.resources          = 'LSPhotoSelect/Assets.xcassets/*'
  
  s.ios.deployment_target = '8.0'
  s.requires_arc = true # 是否启用ARC
  s.source_files = 'LSPhotoSelect/**/*'
  
  # s.resource_bundles = {
    # 'LSPhotoSelect' => ['LSPhotoSelect/Assets.xcassets/*']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'Foundation'
  s.dependency 'Masonry'
end
