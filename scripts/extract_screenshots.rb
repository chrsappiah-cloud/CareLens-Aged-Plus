#!/usr/bin/env ruby
# Extracts PNG screenshots from an .xcresult bundle produced by UI tests.

require "fileutils"
require "json"
require "open3"

xcresult, out_dir = ARGV
abort "Usage: extract_screenshots.rb <path.xcresult> <output_dir>" unless xcresult && out_dir

FileUtils.mkdir_p(out_dir)

json, status = Open3.capture2(
  "xcrun", "xcresulttool", "get", "object", "--legacy",
  "--path", xcresult,
  "--format", "json"
)
abort "xcresulttool failed" unless status.success?

data = JSON.parse(json)
actions = data.dig("actions", "_values") || []
exported = 0

actions.each do |action|
  tests = action.dig("actionResult", "testsRef", "id", "_value")
  next unless tests

  tests_json, = Open3.capture2(
    "xcrun", "xcresulttool", "get", "object", "--legacy",
    "--path", xcresult, "--id", tests, "--format", "json"
  )
  suites = JSON.parse(tests_json).dig("summaries", "_values") || []

  suites.each do |suite|
    (suite.dig("tests", "_values") || []).each do |test_group|
      (test_group.dig("subtests", "_values") || []).each do |test|
        (test.dig("attachments", "_values") || []).each do |attachment|
          name = attachment.dig("name", "_value")
          payload_id = attachment.dig("payloadRef", "id", "_value")
          next unless name && payload_id && name.match?(/^\d{2}_/)

          dest = File.join(out_dir, "#{name}.png")
          system(
            "xcrun", "xcresulttool", "export", "--legacy",
            "--path", xcresult,
            "--id", payload_id,
            "--output-path", dest,
            out: File::NULL, err: File::NULL
          )
          exported += 1 if File.exist?(dest)
          puts "Exported #{dest}" if File.exist?(dest)
        end
      end
    end
  end
end

puts "Total exported: #{exported} -> #{out_dir}"
