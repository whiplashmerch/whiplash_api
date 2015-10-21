module WhiplashApi
  class Item < Base
    class << self
      def count(args={})
        self.get(:count, args)
      end

      def sku(sku, args={})
        sanitize_as_resource self.get(:sku, { sku: sku }.merge(args))
      end

      def group(id, args={})
        sanitize_as_resource self.get("group/#{id}", args)
      end

      def originator(id, args={})
        sanitize_as_resource self.get("originator/#{id}", args)
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

      def delete(*args)
        super
      rescue WhiplashApi::RecordNotFound
        raise RecordNotFound, "No Item was found with given ID."
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
