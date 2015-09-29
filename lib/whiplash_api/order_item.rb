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

      # FIXME: this feels a bit hackish, but there was no easy way to implement
      # this API endpoint.
      def originator(id, args={})
        self.collection_name = "order_items/originator"
        order = self.find(id, args)
        self.collection_name = "order_items"
        order
      end

      def find_or_create_by_originator_id(id, args={})
        originator(id) || create(args.merge(originator_id: id))
      end

      def create(args={})
        required! args, "%s is required for creating the order item.",
          "Order ID", "Item ID", "Quantity"
        super
      end

      def update(id, args={})
        order_item = self.find(id)
        raise Error, "No order item found with given ID." unless order_item

        if args[:order_id].present?
          order = WhiplashApi::Order.find(args[:order_id])
          raise Error, "No such order found to switch to." unless order
          raise Error, "You can only switch to unshipped orders." unless order.unshipped?
        end

        order_item.update_attributes(args) ? order_item : false
      end

      # FIXME: throws 401 authentication error. Must confirm with James.
      def delete(id, args={})
        order_item = self.find(id)
        order = WhiplashApi::Order.find(order_item.order_id)
        if order.unprocessed? || order.being_processed?
          super
        else
          raise Error, "You can not delete order items for orders which have already been processed."
        end
      end
    end
  end
end
