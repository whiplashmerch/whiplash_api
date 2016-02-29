module WhiplashApi
  class WebHook < Base
    class << self

      def delete(*args)
        super
      rescue WhiplashApi::RecordNotFound
        raise RecordNotFound, "No Web Hook was found with given ID."
      end

    end

    # instance methods
    def destroy(args={})
      self.class.delete(self.id, args)
    end
  end
end
