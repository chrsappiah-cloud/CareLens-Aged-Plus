#!/usr/bin/env ruby
require "spaceship"

key_id = ENV["APP_STORE_CONNECT_API_KEY_ID"] || ENV["ASC_KEY_ID"]
issuer_id = ENV["APP_STORE_CONNECT_ISSUER_ID"] ||
  ENV["APP_STORE_CONNECT_API_KEY_ISSUER_ID"] || ENV["ASC_ISSUER_ID"]
key_path = File.expand_path("~/.appstoreconnect/private_keys/AuthKey_#{key_id}.p8")

token = Spaceship::ConnectAPI::Token.create(
  key_id: key_id,
  issuer_id: issuer_id,
  filepath: key_path
)
Spaceship::ConnectAPI.token = token

app = Spaceship::ConnectAPI::App.get(app_id: ENV.fetch("ASC_APP_ID", "6767072418"))
version = app.get_edit_app_store_version(platform: Spaceship::ConnectAPI::Platform::IOS)

if version
  puts "version=#{version.version_string} state=#{version.app_store_state}"
  build = version.build
  puts "selected_build=#{build ? build.version : 'none'}"
else
  puts "no_editable_version"
end

submissions = Spaceship::ConnectAPI.get_review_submissions(
  filter: { app: app.id },
  includes: "items"
).all

submissions.each do |submission|
  puts "submission id=#{submission.id} state=#{submission.state}"
end
