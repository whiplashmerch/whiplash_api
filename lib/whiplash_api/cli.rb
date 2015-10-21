require 'pry'

# An example implementation of this gem.
module WhiplashApi
  class CLI < Thor

    class_option :test,  boolean: true, desc: "run using test API endpoints."
    class_option :local, boolean: true, desc: "run using localhost API endpoints."

    desc "list [API_KEY]", "Fetch items for the current account"
    def list(api_key = nil)
      setup! api_key

      items = WhiplashApi::Item.all
      items.each do |item|
        message  = "%16s" % item.sku
        message += "%20s" % item.description
        message += "  %3s  " % (item.available ? "Yes" : "No")
        message += item.title
        say_status "Product", message
      end
    end

    desc "sku ID [API_KEY]", "Fetch item by SKU"
    def sku(id, api_key = nil)
      setup! api_key

      item = WhiplashApi::Item.sku id
      message  = "%16s" % item.sku
      message += "%20s" % item.description
      message += "  %3s  " % (item.available ? "Yes" : "No")
      message += item.title
      say_status "Product", message
    end

    desc "test", "test"
    def test
      setup!
      binding.pry
    end

    private

    def setup!(api_key = nil)
      WhiplashApi::Base.api_key = api_key || ENV['WL_KEY']
      WhiplashApi::Base.testing! if ENV['API_ENV'] == "test" || options[:test]
    end
  end
end
