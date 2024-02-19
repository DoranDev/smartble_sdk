#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint smartble_sdk.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'smartble_sdk'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter project.'
  s.description      = <<-DESC
A new Flutter project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*','Resource/**/*'
  s.dependency 'Flutter'
  s.dependency 'SnapKit'
  s.dependency 'iOSDFULibrary', '~> 4.13.0'
  s.vendored_frameworks='FR/GRDFUSDK.framework',
  'FR/JL_BLEKIT.framework',
  'FR/JLDialUnit.framework',
  'FR/ZipZap.framework'
  s.platform = :ios, '9.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
