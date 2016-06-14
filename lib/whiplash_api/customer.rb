module WhiplashApi
  class Customer < Base
    class << self

      def count(args={})
        self.get(:count, args)
      end
      
    end
  end
end
