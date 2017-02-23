$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'pry'
require 'whiplash_api'
require 'webmock/rspec'
WebMock.allow_net_connect!

module WhiplashApi
  module TestHelpers
    def self.setup!
      version = (ENV['WL_API_VERSION'] || WhiplashApi::DEFAULT_API_VERSION).to_i
      raise "Please, set a valid API version" if version == 0
      raise "Please, set environment variable WL_API_KEY" if version == 1 && !ENV['WL_API_KEY']
      raise "Please, set environment variable WL_OAUTH_KEY" if version > 1 && !ENV['WL_OAUTH_KEY']
      WhiplashApi::Base.testing!
      WhiplashApi::Base.api_version = version
      WhiplashApi::Base.api_key = version == 1 ? ENV['WL_API_KEY'] : ENV['WL_OAUTH_KEY']
    end

    def self.teardown!
      return if ENV['NO_TEARDOWN'].present?
      setup!

      puts "Removing/cancelling resources remaining from previous/current tests..."
      puts "This may take a while..."

      # remove all created items
      skus = %w{SOME-SKU-KEY SOME-SKU-KEY-2 SOME-SKU-KEY-3 SOME-SKU-KEY-4}
      skus.map do |sku|
        WhiplashApi::Item.sku(sku) rescue []
      end.flatten.compact.each(&:destroy)

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
  config.before(:each) do
    WhiplashApi::TestHelpers.setup!

    stub_request(:get, /getwhiplash.com\/api\/customers\/count.json/).to_return(status: 200, body: "2")

    stub_request(:get, /getwhiplash.com\/api\/customers\/\d+.json/).
      to_return(status: 200, body: "{\"billing_address1\":\"123 Some Street\",\"billing_address2\":\"\",\"billing_address3\":null,\"billing_city\":\"Ann Arbor\",\"billing_company\":\"Whiplash Merchandising\",\"billing_contact_name\":\"Test User\",\"billing_country\":\"US\",\"billing_phone1\":\"\",\"billing_phone2\":\"\",\"billing_state\":\"MI\",\"default_warehouse_id\":1,\"id\":1,\"name\":\"Whiplash\"}", headers: {})

    stub_request(:get, /getwhiplash.com\/api\/customers.json/).
      to_return(status: 200, body: "[{\"billing_address1\":\"\",\"billing_address2\":\"\",\"billing_address3\":null,\"billing_city\":\"\",\"billing_company\":\"Test Records\",\"billing_contact_name\":\"Test User\",\"billing_country\":\"US\",\"billing_phone1\":\"\",\"billing_phone2\":\"\",\"billing_state\":\"\",\"default_warehouse_id\":1,\"id\":1,\"name\":\"Test Recordings\"},{\"billing_address1\":\"123 Some St\",\"billing_address2\":\"\",\"billing_address3\":null,\"billing_city\":\"San Francisco\",\"billing_company\":null,\"billing_contact_name\":\"Test User\",\"billing_country\":\"US\",\"billing_phone1\":\"\",\"billing_phone2\":\"\",\"billing_state\":\"CA\",\"default_warehouse_id\":2,\"id\":2,\"name\":\"Test Clothing\"}]", headers: {})

    stub_request(:get, /getwhiplash.com\/api\/users\/me.json/).
      to_return(status: 200, body: "{\"email\":\"test@testers.com\",\"first_name\":\"Test\",\"id\":1,\"last_name\":\"User\",\"role\":\"customer\",\"warehouse_id\":null,\"customer_ids\":[1,2]}")
  end

  config.before(:suite) do
    WhiplashApi::TestHelpers.teardown!
  end

  config.after(:suite) do
    puts
    WhiplashApi::TestHelpers.teardown!
  end
end
