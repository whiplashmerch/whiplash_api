module WhiplashAPI
  
  class Order < Base
    class << self
      def status(status, args={})
        self.get(:status, {:status => status}.merge(args))
      end
      
      def originator(id, args={})
        self.get(:originator, {:originator_id => id}.merge(args))
      end
    end
  end

end