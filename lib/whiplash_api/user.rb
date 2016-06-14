module WhiplashApi
  class User < Base
    class << self

      def me
        self.get(:me)
      end

    end
  end
end
