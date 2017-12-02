module Devise
  module Strategies
    class Fake < Authenticatable
      def authenticate!
        resource = mapping.to.find_by(
          username: authentication_hash[:username])
        return fail(:not_found_in_database) unless resource

        success!(resource)
      end
    end
  end
end
