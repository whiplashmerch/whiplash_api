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
        order = self.find(id, args)
        self.collection_name = "order_items"
        order
      end

      def find_or_create_by_originator_id(id, args={})
        originator(id) || create(args.merge(originator_id: id))
      end

      def update(id, args={})
        order_item = self.find(id)

        if args[:order_id].present?
          order = WhiplashApi::Order.find(args[:order_id])
        else
          order = WhiplashApi::Order.find(order_item.order_id)
        end

        raise Error, "You can only switch to unshipped orders." unless order.unshipped?
        order_item.update_attributes(args) ? order_item : false
      rescue WhiplashApi::RecordNotFound
        message = order_item.present? ? "No such order found to switch to." : "No order item found with given ID."
        raise RecordNotFound, message
      end

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

    # instance methods
    def destroy
      self.class.delete(self.id)
    end
  end
end
