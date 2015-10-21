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
        response = self.put(id, {}, args.to_json)
        response.code.to_i >= 200 && response.code.to_i < 300
      rescue WhiplashApi::RecordNotFound
        raise RecordNotFound, "No shipnotice item found with given ID."
      end

      def delete(*args)
        super
      rescue WhiplashApi::RecordNotFound
        raise RecordNotFound, "No shipnotice item found with given ID."
      end
    end

    # instance methods
    def destroy
      self.class.delete(self.id)
    end
  end
end
