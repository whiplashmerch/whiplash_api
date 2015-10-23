module WhiplashApi
  class Error < ::StandardError; end
  class RecordNotFound < Error; end

  class Base < ActiveResource::Base
    self.site   = 'https://www.whiplashmerch.com/api/'
    self.format = :json

    class << self
      def testing!
        self.site = 'http://testing.whiplashmerch.com/api/'

        ActiveSupport::Notifications.subscribe("request.active_resource") do |*args|
          puts "[ActiveResource] Request:  #{args.last[:request_uri]}"
          puts "[ActiveResource] Response: #{args.last[:result].body}"
        end if ENV['DEBUG'].present?
      end

      # Override the connection that ActiveResource uses, so that we can add our
      # own error messages for the weird cases when API returns 422 error.
      def connection(refresh = false)
        message = "You must set a valid API Key. Current: #{headers['X-API-KEY'].inspect}"
        raise WhiplashApi::Error, message if headers['X-API-KEY'].blank?
        @connection = WhiplashApi::Connection.new(site, format) if refresh || @connection.nil?
        super
      end

      def headers
        Thread.current["active.resource.currentthread.headers"] = {} if Thread.current["active.resource.currentthread.headers"].blank?
        Thread.current["active.resource.currentthread.headers"]
      end

      def api_key=(api_key)
        headers['X-API-KEY'] = api_key
      end

      def api_version=(v = nil)
        headers['X-API-VERSION'] = v || 1
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
