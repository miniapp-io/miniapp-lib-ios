Pod::Spec.new do |s|
  s.name             = 'MiniAppX'
  s.version          = '1.0.16'
  s.summary          = 'MiniAppX is an iOS framework for Web3 MiniApp, supporting pluginization, authentication, Bot, MiniApp, and more.'
  s.description      = <<-DESC
    MiniAppX provides runtime support for Web3 MiniApp, including plugin management, authentication, Bot services, MiniApp services, etc., suitable for the iOS platform.
  DESC
  s.homepage         = 'https://github.com/miniapp-io/miniapp-lib-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author           = { 'w3bili' => 'w3bili@proton.me' }
  s.ios.deployment_target = "13.0"
  s.swift_version    = '5.0'
  s.source           = { :git => 'https://github.com/miniapp-io/miniapp-lib-ios.git', :tag => s.version.to_s }

  s.public_header_files = 'MiniAppX.h'
  s.source_files     = '**/*.{h,swift}'
  s.resource_bundles = {
    'MiniAppXResources' => ['MiniAppXResources.bundle/**/*']
  }
  
  s.dependency 'MiniAppUIKit'

end
