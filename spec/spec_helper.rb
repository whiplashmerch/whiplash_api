$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'pry'
require 'whiplash_api'

message = "You must set environment variable WL_KEY for specifying the test API key."
raise WhiplashApi::Error, message unless ENV['WL_KEY'].present?

WhiplashApi::Base.testing!
WhiplashApi::Base.api_key = ENV['WL_KEY']

module WhiplashApi
  module TestHelpers
    def self.teardown!
      # remove all created items
      skus = %w{SOME-SKU-KEY SOME-SKU-KEY-2 SOME-SKU-KEY-3 SOME-SKU-KEY-4}
      skus.map do |sku|
        WhiplashApi::Item.sku(sku) rescue []
      end.flatten.each(&:destroy)

      # cancel all created orders
      orders = WhiplashApi::Order.all(params: { shipping_country: "TS" }) rescue []
      order_items = orders.map{|order| WhiplashApi::OrderItem.all(params: {order_id: order.id})}.flatten
      order_items.each(&:destroy)

      # delete all shipnotices
      notices  = WhiplashApi::Shipnotice.all.select{|sn| sn.name = "Some Name" && sn.warehouse_id == 1}
      sn_items = notices.map{|notice| WhiplashApi::ShipnoticeItem.all(params: {shipnotice_id: notice.id})}.flatten
      sn_items.each(&:destroy)
      notices.each(&:destroy)
    end
  end
end

RSpec.configure do |config|
  # config.before(:suite) do
  #   puts "Removing/cancelling resources that may interfere with current tests..."
  #   puts "This may take a while..."

  #   WhiplashApi::TestHelpers.teardown!
  # end

  config.after(:suite) do
    puts
    puts "Removing/cancelling resources created while testing..."
    puts "This may take a while..."

    WhiplashApi::TestHelpers.teardown!
  end
end
