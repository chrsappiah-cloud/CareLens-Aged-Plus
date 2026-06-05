#!/usr/bin/env ruby
# Extracts PNG screenshots from an .xcresult bundle produced by UI tests.

require "fileutils"
require "json"
require "open3"
require "tmpdir"

xcresult, out_dir = ARGV
abort "Usage: extract_screenshots.rb <path.xcresult> <output_dir>" unless xcresult && out_dir

FileUtils.mkdir_p(out_dir)

tmpdir = Dir.mktmpdir("carelens-screenshots-")
manifest_path = File.join(tmpdir, "manifest.json")

status = system(
  "xcrun", "xcresulttool", "export", "attachments",
  "--path", xcresult,
  "--output-path", tmpdir,
  out: File::NULL
)
abort "xcresulttool export attachments failed" unless status && File.exist?(manifest_path)

manifest = JSON.parse(File.read(manifest_path))
exported = 0

manifest.each do |entry|
  (entry["attachments"] || []).each do |attachment|
    next if attachment["isAssociatedWithFailure"]

    suggested = attachment["suggestedHumanReadableName"].to_s
    next unless suggested.match?(/^\d{2}_/)

    base_name = suggested.split("_0_").first
    source = File.join(tmpdir, attachment["exportedFileName"])
    next unless File.exist?(source)

    dest = File.join(out_dir, "#{base_name}.png")
    FileUtils.cp(source, dest)
    exported += 1
    puts "Exported #{dest}"
  end
end

FileUtils.rm_rf(tmpdir)
puts "Total exported: #{exported} -> #{out_dir}"
abort "No screenshots exported" if exported.zero?
