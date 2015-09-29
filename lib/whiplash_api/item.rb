module WhiplashApi
  class Item < Base
    class << self
      def sku(sku, args={})
        self.get(:sku, { sku: sku }.merge(args)).map{ |item| self.new(item) }
      end

      def originator(id, args={})
        self.get(:originator, {originator_id: id}.merge(args)).map{ |item| self.new(item) }
      end

      # Find items with given ID or SKU, or else, create a new item.
      def find_or_create(args={})
        item = self.find(args[:id]) if args[:id]
        item = self.first_by_sku(args[:sku]) if !item && args[:sku]
        item ? item : create(args)
      end

      def find_or_create_by_sku(sku, args={})
        first_by_sku(sku) || create(args.merge(sku: sku))
      end

      def find_or_create_by_originator_id(id, args={})
        originator(id) || create(args.merge(originator_id: id))
      end

      # Note: Ideally, the API service should reject create requests that do not
      # contain the required keys. But, in my testing, I found that API was
      # allowing creation of items without providing a SKU.
      #
      def create(args={})
        required! args, "%s is required for creating the item.", %w[SKU Title]
        super
      end

      def update(args={})
        required! args, "%s is required for updating the item.", %w[SKU]

        item = self.first_by_sku(args.delete(:sku))
        raise Error, "No item found with given SKU." unless item
        item.update_attributes(args) ? item : false
      end

      # additional useful methods:
      def first_by_sku(sku, args={})
        self.sku(sku, args).first
      end

      # FIXME: throws 401 authentication error. Must confirm with James.
      def delete(id, args={}); end
    end

    # Instance method to deactivate the current item.
    def destroy(args={})
      self.class.delete(self.id, args)
    end
  end
end
