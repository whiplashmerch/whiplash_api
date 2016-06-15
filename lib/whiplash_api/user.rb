module WhiplashApi
  class User < Base
    class << self

      def me
        self.get(:me)
        sanitize_as_resource self.get(:me)
      end

    end
  end
end
