module WhiplashApi
  class Order < Base
    class << self
      def status_for(status)
        status_mapping[status].to_s.titleize
      end
      def status_code_for(status)
        status_mapping.invert[status.to_s.underscore.to_sym]
      end

      def count(args={})
        self.get(:count, args)
      end

      def originator(id, args={})
        sanitize_as_resource self.get("originator/#{id}", args)
      end

      def find_or_create_by_originator_id(id, args={})
        originator(id) || create(args.merge(originator_id: id))
      end

      def update(args={})
        order = self.originator(args[:originator_id])
        raise RecordNotFound, "No order found with given Originator ID." unless order
        order.update_attributes(args) ? order : false
      end

      def pause(id, args={})
        self.put("#{id}/pause")
      end

      def release(id, args={})
        self.put("#{id}/release")
      end

      def cancel(id, args={})
        self.put("#{id}/cancel")
      end

      def uncancel(id, args={})
        self.put("#{id}/uncancel")
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
    alias :processing? :being_processed?

    def pause
      self.put(:pause)
    end

    def release
      self.put(:release)
    end

    def cancel
      self.put(:cancel)
    end

    def uncancel
      self.put(:uncancel)
    end

    # def pause
    #   self.put(:pause) and return if unshipped?
    #   raise Error, "Orders may only be paused before they have been shipped."
    # end

    # def release
    #   self.put(:release) and return if paused?
    #   raise Error, "Cannot release an order that has not been paused."
    # end

    # def cancel
    #   self.put(:cancel) and return if unshipped?
    #   raise Error, "Orders may only be cancelled before they have been shipped."
    # end

    # def uncancel
    #   self.put(:uncancel) and return if cancelled?
    #   raise Error, "Cannot uncancel an order that has not been cancelled."
    # end
  end
end
