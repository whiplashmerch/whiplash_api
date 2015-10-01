module WhiplashApi
  class Connection < ActiveResource::Connection
    private

    def request(*arguments)
      super
    rescue ActiveResource::ResourceInvalid => e
      data = JSON.parse e.response.body
      case
      when data['error'].present? && data['error'].downcase =~ /record.*not.*found/
        raise WhiplashApi::RecordNotFound
      when data['error'].present?
        raise WhiplashApi::Error, data['error'].humanize
      when data['errors'].present? && data['errors']['base'].present?
        messages = data['errors']['base']
        raise WhiplashApi::Error, "Errors were encountered while creating the resource.\n- #{messages.join("\n- ")}"
      when data['errors'].present?
        messages = data['errors'].map{|k,v| v.map{|message| "#{k.humanize} #{message}"}}.flatten
        raise WhiplashApi::Error, "Errors were encountered while creating the resource.\n- #{messages.join("\n- ")}"
      else
        raise WhiplashApi::Error, "Errors were encountered while creating the resource.\nResponse was: #{e.response.body}"
      end
    end
  end
end

