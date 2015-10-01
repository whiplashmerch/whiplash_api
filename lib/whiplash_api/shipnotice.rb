module WhiplashApi
  class Shipnotice < Base
    class << self

      def status_for(status_code)
        status_mapping[status_code].to_s.titleize
      end
      def status_code_for(status)
        status_mapping.invert[status.to_s.underscore.to_sym]
      end

      def warehouse_for(warehouse_code)
        warehouse_mapping[warehouse_code].to_s.titleize
      end
      def warehouse_code_for(warehouse)
        warehouse_mapping.invert[warehouse]
      end

      # def create(args={})
      #   required! args, "%s is required for creating the Shipment Notice.",
      #     "Sender", "ETA", "Warehouse ID", "ShipNotice Items"
      #   super
      # end

      def update(id, args={})
        notice = self.find(id)
        if notice.received?
          raise Error, "Shipment notices may only be updated before they have been received."
        else
          notice.update_attributes(args) ? notice : false
        end
      rescue WhiplashApi::RecordNotFound
        raise RecordNotFound, "No Shipment notice found with given ID."
      end

      # FIXME: throws 401 authentication error. Must confirm with James.
      def delete(id, args={})
        notice = self.find(id)
        if notice.received?
          raise Error, "Shipment notices may only be deleted before they have been received."
        else
          super
        end
      rescue WhiplashApi::RecordNotFound
        raise RecordNotFound, "No Shipment notice found with given ID."
      end

      private

      def status_mapping
        {
          25  => :unexpected,
          50  => :draft,
          100 => :in_transit,
          150 => :arrived,
          200 => :processing,
          250 => :problem,
          300 => :completed,
        }
      end

      def warehouse_mapping
        { 1 => "Ann Arbor", 2 => "San Francisco", 3 => "London" }
      end
    end

    # instance methods
    def received?
      self.status.to_i > 100
    end

    def processed?
      self.status.to_i > 200
    end
  end
end
