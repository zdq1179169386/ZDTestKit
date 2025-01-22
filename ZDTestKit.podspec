Pod::Spec.new do |s|
  s.name             = 'ZDTestKit'
  s.version          = '0.0.1'
  s.summary          = 'A short description of ZDTestKit.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/zdq1179169386/ZDTestKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zdq1179169386' => '2259434901@qq.com' }
  s.source           = { :git => 'https://github.com/zdq1179169386/ZDTestKit.git', :tag => 'v1.2' }
  s.swift_versions = '5.0'
  s.ios.deployment_target = '11.0'
  s.requires_arc = true

  s.source_files = 'Source/Classes/**/*'
  
end
