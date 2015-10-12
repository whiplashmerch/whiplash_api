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

      def update(id, args={})
        shipnotice_item = self.find(id)

        if args[:shipnotice_id].present?
          notice = WhiplashApi::Shipnotice.find(args[:shipnotice_id])
        else
          notice = WhiplashApi::Shipnotice.find(shipnotice_item.shipnotice_id)
        end

        raise Error, "You can not update shipnotice items for shipnotices that have arrived." if notice.received?
        shipnotice_item.update_attributes(args) ? shipnotice_item : false
      rescue WhiplashApi::RecordNotFound
        raise RecordNotFound, "No shipnotice item found with given ID."
      end

      def delete(id, args={})
        snitem = self.find(id)
        notice = WhiplashApi::Shipnotice.find(snitem.shipnotice_id)
        if notice.received?
          raise Error, "You can not delete shipnotice items for shipnotices which have arrived."
        else
          super
        end
      end
    end

    # instance methods
    def destroy
      self.class.delete(self.id)
    end
  end
end
