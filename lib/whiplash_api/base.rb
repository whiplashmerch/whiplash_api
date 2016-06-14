module WhiplashApi
  class Error < ::StandardError; end
  class RecordNotFound < Error; end

  class Base < ActiveResource::Base
    self.site   = 'https://www.whiplashmerch.com/api/'
    self.format = :json

    class << self
      attr_accessor :api_version, :api_key, :customer_id, :shop_id

      def testing!
        # self.site = 'https://testing.whiplashmerch.com/api/'
        self.site = 'http://localhost:3000/api/'

        ActiveSupport::Notifications.subscribe("request.active_resource") do |*args|
          puts "[ActiveResource] Headers: #{WhiplashApi::Base.headers}"
          puts "[ActiveResource] Request:  #{args.last[:request_uri]}"
          puts "[ActiveResource] Response: #{args.last[:result].body}"
        end if ENV['DEBUG'].present?
      end

      # Override the connection that ActiveResource uses, so that we can add our
      # own error messages for the weird cases when API returns 422 error.
      def connection(refresh = false)
        @connection = WhiplashApi::Connection.new(site, format) if refresh || @connection.nil?
        super
      end

      def headers
        Thread.current["active.resource.currentthread.headers"] = {} if Thread.current["active.resource.currentthread.headers"].blank?
        Thread.current["active.resource.currentthread.headers"]
      end

      def api_version
        @api_version ||= WhiplashApi::DEFAULT_API_VERSION
      end

      def api_version=(v = nil)
        @api_version = v.to_i > 0 ? v.to_i : WhiplashApi::DEFAULT_API_VERSION
        headers['X-API-VERSION'] = @api_version.to_s

        # If we change the version, update the headers
        unless api_key.blank?
          if @api_version == 1
            headers.delete('Authorization')
            headers['X-API-KEY'] = api_key
          else
            headers.delete('X-API-KEY')
            headers['Authorization'] = "Bearer #{api_key}"
          end
        end
      end

      def api_key=(api_key)
        @api_key = api_key
        raise Error, "You must set a valid API Key." if @api_key.blank?

        if api_version == 1
          headers.delete('Authorization')
          headers['X-API-KEY'] = @api_key
        else
          headers.delete('X-API-KEY')
          headers['Authorization'] = "Bearer #{@api_key}"
        end
      end

      def customer_id=(customer_id = nil)
        @customer_id = customer_id
        headers['X-CUSTOMER-ID'] = customer_id.to_s
      end

      def shop_id=(shop_id = nil)
        @shop_id = shop_id
        headers['X-SHOP-ID'] = shop_id.to_s
      end

      def reset_headers!
        %w[X-API-KEY X-API-VERSION Authorization].each do |key|
          headers.delete(key)
        end
      end

      protected

      def sanitize_as_resource(collection)
        return collection if collection.blank?
        as_array   = collection.is_a?(Array)
        collection = [collection].flatten.map do |resource|
          resource = self.new(resource)
          resource.instance_variable_set("@persisted", true)
          resource
        end
        as_array ? collection : collection.first
      end
    end
  end
end
