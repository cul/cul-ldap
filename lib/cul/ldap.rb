require "net/ldap"
require "cul/ldap/version"
require "cul/ldap/entry"

module Cul
  class LDAP
    COLUMBIA_HOST = "ldap.columbia.edu"
    COLUMBIA_PORT = "389"

    def initialize
      connection
    end

    # LDAP lookup based on UNI. If record could not be found returns nil.
    #
    # @param [String] uni
    # @return [Cul::LDAP::Entry] containing all the ldap information available for the uni given
    # @return [nil] if record for uni could not be found
    def find_by_uni(uni)
      entries = @connection.search(:base => "o=Columbia University, c=US", :filter => Net::LDAP::Filter.eq("uid", uni))
      (entries.empty?) ? nil : Entry.new(entries.first)
    end

    def connection
      @connection ||= build_connection
    end

    private

    def build_connection
      Net::LDAP.new( { :host => COLUMBIA_HOST, :port => COLUMBIA_PORT } )
    end
  end
end
