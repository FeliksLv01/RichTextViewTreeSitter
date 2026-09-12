#!/usr/bin/env ruby

require 'digest'
require 'open3'

root = File.expand_path('..', __dir__)
version = File.read(File.join(root, 'VERSION')).strip
release_dir = File.join(root, '.build', 'release')
modules = %w[TreeSitter SwiftTreeSitter TreeSitterSwift]

checksums = modules.to_h do |mod|
  path = File.join(release_dir, "#{mod}.xcframework.zip")
  abort "Missing #{path}" unless File.file?(path)
  checksum, error, status = Open3.capture3('swift', 'package', 'compute-checksum', path)
  abort "Failed to checksum #{path}: #{error}" unless status.success?
  [mod, checksum.strip]
end

combined = File.join(release_dir, 'RichTextViewTreeSitter.xcframeworks.zip')
abort "Missing #{combined}" unless File.file?(combined)
combined_sha = Digest::SHA256.file(combined).hexdigest

package_path = File.join(root, 'Package.swift')
package = File.read(package_path)
package.sub!(/let version = "[^"]+"/, "let version = \"tree-sitter-#{version}\"") or abort 'Package version not updated'
modules.each do |mod|
  pattern = /(name: "#{mod}",[\s\S]*?checksum: ")[0-9a-f]{64}("\n\s*\))/
  package.sub!(pattern, "\\1#{checksums.fetch(mod)}\\2") or abort "#{mod} checksum not updated"
end
File.write(package_path, package)

podspec_path = File.join(root, 'RichTextViewTreeSitterBinary.podspec')
podspec = File.read(podspec_path)
podspec.sub!(/s\.version = '[^']+'/, "s.version = '#{version}'") or abort 'Podspec version not updated'
podspec.sub!(/:sha256 => '[0-9a-f]{64}'/, ":sha256 => '#{combined_sha}'") or abort 'Podspec SHA not updated'
File.write(podspec_path, podspec)

puts "version=#{version}"
modules.each { |mod| puts "#{mod}=#{checksums.fetch(mod)}" }
puts "pod_sha256=#{combined_sha}"
