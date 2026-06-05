#!/usr/bin/env ruby
# Submit CareLens Aged+ 1.0 (build 4) for App Review via App Store Connect API.
require "spaceship"

key_id = ENV["APP_STORE_CONNECT_API_KEY_ID"] || ENV["ASC_KEY_ID"]
issuer_id = ENV["APP_STORE_CONNECT_ISSUER_ID"] ||
  ENV["APP_STORE_CONNECT_API_KEY_ISSUER_ID"] || ENV["ASC_ISSUER_ID"]
key_path = File.expand_path("~/.appstoreconnect/private_keys/AuthKey_#{key_id}.p8")

abort "Missing ASC API credentials" unless key_id && issuer_id && File.exist?(key_path)

token = Spaceship::ConnectAPI::Token.create(
  key_id: key_id,
  issuer_id: issuer_id,
  filepath: key_path
)
Spaceship::ConnectAPI.token = token

platform = Spaceship::ConnectAPI::Platform::IOS
app = Spaceship::ConnectAPI::App.get(app_id: ENV.fetch("ASC_APP_ID", "6767072418"))
version = app.get_edit_app_store_version(platform: platform)
abort "No editable App Store version found" unless version

build = version.build
abort "No build selected on version #{version.version_string}" unless build
puts "Version #{version.version_string} (#{version.app_store_state}) uses build #{build.version}"

submissions = app.get_review_submissions(
  filter: { platform: platform },
  includes: "items"
)
submissions.each do |submission|
  puts "Submission #{submission.id} state=#{submission.state}"
  next unless [
    Spaceship::ConnectAPI::ReviewSubmission::ReviewSubmissionState::UNRESOLVED_ISSUES,
    Spaceship::ConnectAPI::ReviewSubmission::ReviewSubmissionState::READY_FOR_REVIEW,
    Spaceship::ConnectAPI::ReviewSubmission::ReviewSubmissionState::WAITING_FOR_REVIEW,
    Spaceship::ConnectAPI::ReviewSubmission::ReviewSubmissionState::IN_REVIEW
  ].include?(submission.state)

  puts "  Canceling submission #{submission.id}..."
  submission.cancel_submission
end

sleep 5

submission = app.create_review_submission(platform: platform)
puts "Created submission #{submission.id} state=#{submission.state}"

submission.add_app_store_version_to_review_items(app_store_version_id: version.id)
puts "Added version #{version.id} to submission"

result = submission.submit_for_review
puts "Submitted for review: submission #{result.id} state=#{result.state}"
