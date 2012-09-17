module WhiplashAPI
  
  class OrderItem < Base
    class << self
      def originator(id, args={})
        self.get(:originator, {:originator_id => id}.merge(args))
      end
    end
  end

end