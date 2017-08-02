require "net/ldap"

module Cul
  class LDAP < Net::LDAP
    def self.version
      IO.read("VERSION").strip
    end
  end
end
