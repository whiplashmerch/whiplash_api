$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'pry'
require 'whiplash_api'

message = "You must set environment variable WL_KEY for specifying the test API key."
raise WhiplashApi::Error, message unless ENV['WL_KEY'].present?

WhiplashApi::Base.use_test_endpoints!
WhiplashApi::Base.api_key = ENV['WL_KEY']
