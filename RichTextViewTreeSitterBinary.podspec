Pod::Spec.new do |s|
  s.name = 'RichTextViewTreeSitterBinary'
  s.version = '0.25.10.1'
  s.summary = 'Static Tree-sitter XCFrameworks for RichTextView'
  s.description = <<-DESC
    Pinned static XCFramework distributions of Tree-sitter 0.25.10,
    SwiftTreeSitter 0.25.0, and the Swift grammar 0.7.3.
  DESC
  s.homepage = 'https://github.com/FeliksLv01/RichTextViewTreeSitter'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = { 'FeliksLv01' => 'felikslv@163.com' }
  s.source = {
    :http => "https://github.com/FeliksLv01/RichTextViewTreeSitter/releases/download/tree-sitter-#{s.version}/RichTextViewTreeSitter.xcframeworks.zip",
    :sha256 => 'e57f40e373aea962103071b11b884c2e4265fee4c404cbc9496fff8b20d659dd'
  }
  s.ios.deployment_target = '15.0'
  s.swift_versions = ['5.9', '6.0']
  s.vendored_frameworks = 'Artifacts/TreeSitter.xcframework',
                          'Artifacts/SwiftTreeSitter.xcframework',
                          'Artifacts/TreeSitterSwift.xcframework'
  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
end
