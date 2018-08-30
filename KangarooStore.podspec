Pod::Spec.new do |s|
  s.name             = 'KangarooStore'
  s.version          = '1.0'
  s.summary          = 'A very lightweight Core Data framework.'
  s.swift_version    = '4.1'
  s.description      = <<-DESC
  A very lightweight Core Data framework. You\'ll be able to fetch object in an easier way.
  DESC

  s.homepage         = 'https://github.com/DarkySwift/KangarooStore'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Carlos Duclos' => 'darkzeratul64@gmail.com' }
  s.source           = { :git => 'https://github.com/DarkySwift/KangarooStore.git', :tag => s.version.to_s }
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.9"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"
  s.source       = { :git => ".git", :tag => s.version.to_s }
  s.source_files  = "Sources/**/*"
  s.frameworks  = "Foundation"
  
end
