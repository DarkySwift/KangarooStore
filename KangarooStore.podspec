#
# Be sure to run `pod lib lint KangarooStore.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'KangarooStore'
  s.version          = '1.0'
  s.summary          = 'A very lightweight Core Data framework.'
  # s.resources        = 'KangarooStore/Assets/*'
  s.swift_version    = '4.1'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/DarkySwift/KangarooStore'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Carlos Duclos' => 'darkzeratul64@gmail.com' }
  s.source           = { :git => 'https://github.com/DarkySwift/KangarooStore.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'KangarooStore/Classes/**/*'
  
  # s.resource_bundles = {
  #  'KangarooStore' => ['KangarooStore/Assets/**/*.{storyboard,xib,xcassets,imageset,png,jpg}']
  # }
end
