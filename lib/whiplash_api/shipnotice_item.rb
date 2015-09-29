module WhiplashApi
  class ShipnoticeItem < Base
    class << self

      # Finders for ShipnoticeItem require `shipnotice_id` key to be present.
      # The following routine enforces this condition.
      #
      def find(*args)
        scope   = args.slice!(0)
        options = args.slice!(0) || {}

        if [:all, :first, :last, :one].include?(scope)
          invalid = options[:params].to_s.empty? || options[:params][:shipnotice_id].to_s.empty?
          raise Error, "You must supply a Shipment Notice ID (as parameter) to retrieve shipnotice items for." if invalid
        end

        super(scope, options)
      end

      def create(args={})
        required! args, "%s is required for creating the shipnotice item.",
          "Shipnotice ID", "Item ID", "Quantity"
        super
      end

      def update(id, args={})
        shipnotice_item = self.find(id)
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
