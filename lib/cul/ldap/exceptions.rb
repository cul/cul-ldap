module Cul::LDAP::Exceptions
  class Error < StandardError; end
  class AuthError < Error; end
  class InvalidOptionError < Error; end
end