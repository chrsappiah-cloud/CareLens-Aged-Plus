#!/usr/bin/env ruby
# Removes China mainland (CHN) from App Store availability via App Store Connect API.
require "spaceship"

app_id = ENV.fetch("ASC_APP_ID", "6767072418")
key_id = ENV["APP_STORE_CONNECT_API_KEY_ID"] || ENV["ASC_KEY_ID"]
issuer_id = ENV["APP_STORE_CONNECT_ISSUER_ID"] ||
  ENV["APP_STORE_CONNECT_API_KEY_ISSUER_ID"] || ENV["ASC_ISSUER_ID"]
key_path = ENV["APP_STORE_CONNECT_API_KEY_PATH"]
if key_path && key_path.start_with?("~")
  key_path = File.expand_path(key_path)
end
key_path ||= File.expand_path("~/.appstoreconnect/private_keys/AuthKey_#{key_id}.p8")

abort "Missing ASC API key (set APP_STORE_CONNECT_API_KEY_ID, APP_STORE_CONNECT_ISSUER_ID, and key .p8 path)" unless key_id && issuer_id && key_path && File.exist?(key_path)

token = Spaceship::ConnectAPI::Token.create(
  key_id: key_id,
  issuer_id: issuer_id,
  filepath: key_path
)
Spaceship::ConnectAPI.token = token

app = Spaceship::ConnectAPI::App.get(app_id: app_id)
abort "App not found: #{app_id}" unless app

territories = Spaceship::ConnectAPI.get_territories
selected_ids = territories.reject { |t| t.id == "CHN" }.map(&:id)

app.update(
  territory_ids: selected_ids,
  allow_removing_from_sale: true
)

puts "Updated availability: #{selected_ids.count} territories (China excluded)"
