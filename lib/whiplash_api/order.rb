module WhiplashApi
  class Order < Base
    class << self
      def status_for(status)
        status_mapping[status].to_s.titleize
      end
      def status_code_for(status)
        status_mapping.invert[status.to_s.underscore.to_sym]
      end

      # FIXME: this feels a bit hackish, but there was no easy way to implement
      # this API endpoint.
      def originator(id, args={})
        self.collection_name = "orders/originator"
        order = self.find(id, args)
        self.collection_name = "orders"
        order
      end

      def find_or_create_by_originator_id(id, args={})
        originator(id) || create(args.merge(originator_id: id))
      end

      def create(args={})
        required! args, "%s is required for creating the order.",
          "Shipping Name", "Shipping Address 1", "Shipping City",
          "Shipping Zip", "Email"
        super
      end

      # FIXME: updating order status via the API does not update the status_name
      # for the order. This should be resolved at service level to ensure data
      # corruption does not happen.
      #
      def update(args={})
        required! args, "%s is required for creating the order.",
          "Shipping Name", "Shipping Address 1", "Shipping City",
          "Shipping Zip", "Email"

        order = self.originator(args[:originator_id])
        raise Error, "No order found with given Originator ID." unless order

        if order.status.to_i < 300
          order.update_attributes(args) ? order : false
        else
          raise Error, "Orders may only be updated before they have been shipped."
        end
      end

      def pause(id, args={})
        self.find(id, args).pause
      end

      def release(id, args={})
        self.find(id, args).release
      end

      def cancel(id, args={})
        self.find(id, args).cancel
      end

      def uncancel(id, args={})
        self.find(id, args).uncancel
      end

      private

      def status_mapping
        {
          35 =>  :quote,
          40 =>  :cancelled,
          45 =>  :closed_by_originator,
          50 =>  :unpaid,
          75 =>  :pending_return,
          77 =>  :return_verified,
          80 =>  :items_unavailable,
          90 =>  :paused,
          95 =>  :unassignable,
          100 => :processing,
          120 => :printed,
          150 => :picked,
          155 => :prepacking_in_progress,
          160 => :packed,
          200 => :label_scheduled_for_purchase,
          250 => :label_purchased,
          300 => :shipped,
          350 => :delivered,
          400 => :returned_undeliverable,
          410 => :replacement_requested,
          430 => :exchanged,
          450 => :refund_requested
        }
      end
    end

    # instance methods

    def unshipped?
      self.status.to_i < 300
    end

    def paused?
      self.status.to_i == 90
    end

    def cancelled?
      self.status.to_i == 40
    end

    def unprocessed?
      self.status.to_i < 100
    end

    def being_processed?
      self.status.to_i == 100
    end

    def pause
      if unshipped?
        self.put(:pause)
      else
        raise Error, "Orders may only be paused before they have been shipped."
      end
    end

    def release
      if paused?
        self.put(:release)
      else
        raise Error, "Cannot release an order that has not been paused."
      end
    end

    def cancel
      if unshipped?
        self.put(:cancel)
      else
        raise Error, "Orders may only be cancelled before they have been shipped."
      end
    end

    def uncancel
      if cancelled?
        self.put(:uncancel)
      else
        raise Error, "Cannot uncancel an order that has not been cancelled."
      end
    end
  end
end
