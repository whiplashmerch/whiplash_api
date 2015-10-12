module WhiplashApi
  class Error < ::StandardError; end
  class RecordNotFound < Error; end

  class Base < ActiveResource::Base
    self.site   = 'https://www.whiplashmerch.com/api/'
    self.format = :json

    class << self
      def testing!
        self.site = 'http://testing.whiplashmerch.com/api/'
      end

      # Override the connection that ActiveResource uses, so that we can add our
      # own error messages for the weird cases when API returns 422 error.
      def connection(refresh = false)
        message = "You must set a valid API Key. Current: #{headers['X-API-KEY'].inspect}"
        raise WhiplashApi::Error, message if headers['X-API-KEY'].blank?
        @connection = WhiplashApi::Connection.new(site, format) if refresh || @connection.nil?
        super
      end

      def api_key=(api_key)
        headers['X-API-KEY'] = api_key
      end

      def api_version=(v)
        headers['X-API-VERSION'] = v
      end
    end
  end
end
