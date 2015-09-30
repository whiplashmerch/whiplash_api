module WhiplashApi
  class Connection < ActiveResource::Connection
    private

    def request(*arguments)
      super
    rescue ActiveResource::ResourceInvalid => e
      data = JSON.parse e.response.body
      raise WhiplashApi::RecordNotFound if data['error'].downcase =~ /record.*not.*found/
      raise WhiplashApi::Error, data['error'].humanize if data['error'].present?
    end
  end
end

