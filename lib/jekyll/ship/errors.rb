module Jekyll
  module Ship

    class Error < StandardError; end

    class UnrecognizedHostingServiceError < Error
      def initialize(unrecognized_service, available_services)
        msg = "Unrecognized hosting service: \"#{unrecognized_service}\". " \
              "Available services are: #{available_services.keys.join(', ')}"
        super msg
      end
    end
  end
end
