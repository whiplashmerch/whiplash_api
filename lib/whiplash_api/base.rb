module WhiplashApi
  class Error < ::StandardError; end
  class RecordNotFound < Error; end

  class Base < ActiveResource::Base
    self.site   = 'https://www.whiplashmerch.com/api/'
    self.format = :json

    # Thanks to Brandon Keepers for this little nugget:
    # http://opensoul.org/blog/archives/2010/02/16/active-resource-in-practice/
    class << self
      # If headers are not defined in a given subclass, then obtain
      # headers from the superclass.
      def headers
        if defined?(@headers)
          @headers
        elsif superclass != Object && superclass.headers
          superclass.headers
        else
          @headers ||= {}
        end
      end

      def connection(refresh = false)
        @connection = WhiplashApi::Connection.new(site, format) if refresh || @connection.nil?
        super
      end

      def api_key=(api_key)
        headers['X-API-KEY'] = api_key
      end

      def api_version=(v)
        headers['X-API-VERSION'] = v
      end

      def use_local_endpoints!
        self.site = 'http://localhost:3000/api/'
      end

      def use_test_endpoints!
        self.site = 'http://testing.whiplashmerch.com/api/'
      end

      protected

      def required!(args, message, *fields)
        missing = fields.flatten.detect do |field|
          args[field.to_s.parameterize.underscore].to_s.empty? &&
            args[field.to_s.parameterize.underscore.to_sym].to_s.empty?
        end

        raise Error, (message % missing) if missing
      end
    end
  end
end
