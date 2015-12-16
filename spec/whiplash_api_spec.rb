require 'spec_helper'

describe WhiplashApi do

  def doubled(min, max)
    (min..max).map{|val| [val, val*2]}.flatten.sort
  end

  def in_parallel(version, range, klass)
    collected = []
    range.map do |val|
      Thread.new do
        range.max.times do |i|
          WhiplashApi::Base.api_version = version
          WhiplashApi::Base.api_key = (val*i).to_s
          collected.push klass.headers[version == 1 ? 'X-API-KEY' : 'Authorization']
        end
      end
    end.each(&:join)
    collected.sort
  end

  it 'has a version number' do
    expect(WhiplashApi::VERSION).not_to be nil
  end

  context "when API v1" do
    skip("Environment variable WL_API_KEY must be set!") unless ENV['WL_API_KEY']
    it "allows connecting to the API" do
      WhiplashApi::Base.api_version = 1
      WhiplashApi::Base.api_key = ENV['WL_API_KEY']
      expect(WhiplashApi::Item.count).to be > 0
    end

    it "does not mix api key for different classes together" do
      range    = (1..10)
      expected = range.map do |val|
        range.max.times.map{|i| (val*i).to_s }
      end.flatten.sort

      WhiplashApi.constants.select do |klass|
        WhiplashApi.const_get(klass).respond_to?(:headers)
      end.each do |klass|
        actual = in_parallel(1, range, WhiplashApi.const_get(klass))
        expect(actual).to eq(expected), "Thread execution was mixed up for class: WhiplashApi::#{klass}"
      end
    end
  end

  context "when API v2" do
    skip("Environment variable WL_OAUTH_KEY must be set!") unless ENV['WL_OAUTH_KEY']
    it "allows connecting to the API" do
      WhiplashApi::Base.api_version = 2
      WhiplashApi::Base.api_key = ENV['WL_OAUTH_KEY']
      expect(WhiplashApi::Item.count).to be > 0
    end
    xit "supports connecting with a targetted customer ID"

    it "does not mix api key for different classes together" do
      range    = (1..10)
      expected = range.map do |val|
        range.max.times.map{|i| "Bearer #{val*i}" }
      end.flatten.sort

      WhiplashApi.constants.select do |klass|
        WhiplashApi.const_get(klass).respond_to?(:headers)
      end.each do |klass|
        actual = in_parallel(2, range, WhiplashApi.const_get(klass))
        expect(actual).to eq(expected), "Thread execution was mixed up for class: WhiplashApi::#{klass}"
      end
    end
  end
end
