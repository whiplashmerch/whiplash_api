module WhiplashApi
  class OrderItem < Base
    class << self

      # Finders for OrderItem require `order_id` key to be present.
      # The following routine enforces this condition.
      #
      def find(*args)
        scope   = args.slice!(0)
        options = args.slice!(0) || {}

        if [:all, :first, :last, :one].include?(scope)
          invalid = options[:params].to_s.empty? || options[:params][:order_id].to_s.empty?
          raise Error, "You must supply an Order ID (as parameter) to retrieve order items for." if invalid
        end

        super(scope, options)
      end

      def originator(id, args={})
        self.collection_name = "order_items/originator"
        order = self.find(id, args) rescue nil
        self.collection_name = "order_items"
        order
      end

      def find_or_create_by_originator_id(id, args={})
        originator(id) || create(args.merge(originator_id: id))
      end

      def update(id, args={})
        response = self.put(id, {}, args.to_json)
        response.code.to_i >= 200 && response.code.to_i < 300
      rescue WhiplashApi::RecordNotFound
        raise RecordNotFound, "No order item found with given ID."
      end

      def separate(id, args={})
        response = self.post("#{id}/separate")
        sanitize_as_resource JSON.parse(response.body)
      rescue WhiplashApi::RecordNotFound
        raise RecordNotFound, "No order item found with given ID."
      end

      def delete(*args)
        super
      rescue WhiplashApi::RecordNotFound
        raise RecordNotFound, "No order item was found with given ID."
      end

    end

    # instance methods
    def destroy
      self.class.delete(self.id)
    end

    def separate
      self.class.separate(self.id)
    end

  end
end
