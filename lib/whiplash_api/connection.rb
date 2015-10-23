module WhiplashApi
  class Connection < ActiveResource::Connection
    private

    def request(*arguments)
      super
    rescue ActiveResource::ResourceInvalid, ActiveResource::UnauthorizedAccess => e
      data = JSON.parse e.response.body
      case
      when data['error'].present? && data['error'].downcase =~ /record.*not.*found/
        raise WhiplashApi::RecordNotFound, data['error']
      when data['error'].present?
        raise WhiplashApi::Error, "#{e.class}: #{data['error'].humanize}"
      when data['errors'].present? && data['errors']['base'].present?
        messages = data['errors']['base']
        raise WhiplashApi::Error, "Errors were encountered while creating the resource.\n- #{messages.join("\n- ")}"
      when data['errors'].present?
        messages = data['errors'].map{|k,v| v.map{|message| "#{k.humanize} #{message}"}}.flatten
        raise WhiplashApi::Error, "Errors were encountered while creating the resource.\n- #{messages.join("\n- ")}"
      else
        raise
      end
    end
  end
end

