#
# Be sure to run `pod lib lint KangarooStore.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'KangarooStore'
  s.version          = '1.5.4'
  s.summary          = 'A very lightweight Core Data framework.'
  # s.resources        = 'KangarooStore/Assets/*'
  s.swift_version    = '5.0'
  s.description      = <<-DESC
A very lightweight Core Data framework. You\'ll be able to fetch object in an easier way.
                       DESC

  s.homepage         = 'https://github.com/DarkySwift/KangarooStore'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Carlos Duclos' => 'darkzeratul64@gmail.com' }
  s.source           = { :git => 'https://github.com/DarkySwift/KangarooStore.git', :tag => s.version.to_s }

  s.ios.deployment_target = '14.0'
  s.watchos.deployment_target = '6.0'
  s.source_files = 'Sources/**/*'
  
  # s.resource_bundles = {
  #  'KangarooStore' => ['KangarooStore/Assets/**/*.{storyboard,xib,xcassets,imageset,png,jpg}']
  # }
end
