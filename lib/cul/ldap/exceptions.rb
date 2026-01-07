# lib/cul/ldap/exceptions.rb
module Cul
  class LDAP < Net::LDAP
    module Exceptions
      class Error < StandardError; end
      class AuthError < Error; end
      class InvalidOptionError < Error; end
    end
  end
end