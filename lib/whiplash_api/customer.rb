module WhiplashApi
  class Customer < Base
    class << self

      def count(args={})
        self.get(:count, args)[:count]
      end

    end
  end
end
