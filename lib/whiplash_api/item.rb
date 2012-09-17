module WhiplashAPI
  
  class Item < Base
    class << self
      def sku(sku, args={})
        self.get(:sku, {:sku => sku}.merge(args))
      end
      
      def originator(id, args={})
        self.get(:originator, {:originator_id => id}.merge(args))
      end
    end
  end

end