$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'pry'
require 'whiplash_api'

message = "You must set environment variable WL_KEY for specifying the test API key."
raise WhiplashApi::Error, message unless ENV['WL_KEY'].present?

WhiplashApi::Base.use_test_endpoints!
WhiplashApi::Base.api_key = ENV['WL_KEY']

module WhiplashApi
  module TestHelpers
    def self.teardown!
      puts
      puts "Removing/cancelling resources created while testing..."
      puts "This can take a while..."

      # remove all created items
      items = WhiplashApi::Item.sku(@sku) rescue []
      items.each(&:destroy)
      # cancel all created orders
      orders = WhiplashApi::Order.all(params: { shipping_country: "TS" }) rescue []
      order_items = orders.map{|order| WhiplashApi::OrderItem.all(params: {order_id: order.id})}.flatten
      order_items.each(&:destroy)

      notices  = WhiplashApi::Shipnotice.all.select{|sn| sn.name = "Some Name" && sn.warehouse_id == 1}
      sn_items = notices.map{|notice| WhiplashApi::ShipnoticeItem.all(params: {shipnotice_id: notice.id})}.flatten
      sn_items.each(&:destroy)
      notices.each(&:destroy)
    end
  end
end

RSpec.configure do |config|
  config.after(:suite) do
    WhiplashApi::TestHelpers.teardown!
  end
end
