module WhiplashApi
  class Item < Base
    class << self
      def count(args={})
        self.get(:count, args)
      end

      def sku(sku, args={})
        self.get(:sku, { sku: sku }.merge(args)).map{ |item| self.new(item) }
      end

      def originator(id, args={})
        self.collection_name = "items/originator"
        item = self.find(id, args) rescue nil
        self.collection_name = "items"
        item
      end

      def find_or_create(id, args={})
        self.find(id)
      rescue WhiplashApi::RecordNotFound
        create(args)
      end

      def find_or_create_by_sku(sku, args={})
        first_by_sku(sku) || create(args.merge(sku: sku))
      end

      def find_or_create_by_originator_id(id, args={})
        originator(id) || create(args.merge(originator_id: id))
      end

      def update(args={})
        item = self.originator(args[:originator_id])
        raise RecordNotFound, "No item was found with given Originator ID." unless item

        item.update_attributes(args) ? item : nil
      end

      # additional useful methods:
      def first_by_sku(sku, args={})
        self.sku(sku, args).first
      end
    end

    # instance methods
    def destroy(args={})
      self.class.delete(self.id, args)
    end
  end
end
