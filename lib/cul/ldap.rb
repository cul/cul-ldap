require "net/ldap"
require "yaml"

require "cul/ldap/version"
require "cul/ldap/entry"

module Cul
  class LDAP < Net::LDAP
    CONFIG_FILENAME = 'cul_ldap.yml'
    CONFIG_DEFAULTS = {
      host: 'ldap.columbia.edu',
      port: '636',
      encryption: {
        method: :simple_tls,
        tls_options: OpenSSL::SSL::SSLContext::DEFAULT_PARAMS
      }
    }.freeze

    # Create a new Cul::LDAP object
    # @param options [Hash] A set of Net::LDAP constructor options.  See Net::LDAP#initialize for
    #                       the full set of supported options.
    def initialize(options = {})
      super(build_config(options)) # All keys have to be symbols.
    end

    # LDAP lookup based on UNI. If record could not be found returns nil.
    #
    # @param [String] uni
    # @return [Cul::LDAP::Entry] containing all the ldap information available for the uni given
    # @return [nil] if record for uni could not be found, or more than one record was found
    def find_by_uni(uni)
      entries = search(base: "ou=People,o=Columbia University, c=US", filter: Net::LDAP::Filter.eq("uid", uni))
      (entries && entries.count == 1) ? entries.first : nil
    end

    # LDAP lookup based on name.
    #
    # @param [String] name
    # @return [Cul::LDAP::Entry] containing the entry matching this name, if it is unique
    # @return [nil] if record could not be found or if there is more than one match
    def find_by_name(name)
      if name.include?(',')
        name = name.split(',').map(&:strip).reverse.join(" ")
      end
      entries = search(base: "ou=People,o=Columbia University, c=US", filter: Net::LDAP::Filter.eq("cn", name))
      (entries.count == 1) ? entries.first : nil
    end

    # Wrapper around Net::LDAP#search, converts Net::LDAP::Entry objects to
    # Cul::LDAP::Entry objects.
    def search(args = {})
      super(args).tap do |result|
        if result.is_a?(Array)
          result.map!{ |e| Cul::LDAP::Entry.new(e) }
        end
      end
    end

    private

    def build_config(options)
      config = CONFIG_DEFAULTS.merge(options)
      credentials = config.fetch(:auth, nil)
      credentials = nil if !credentials.nil? && credentials.empty?

      # If rails app fetch credentials using rails code, otherwise read from
      # cul_ldap.yml if credentials are nil.
      if credentials.nil?
        credentials = rails_credentials || credentials_from_file
        credentials = nil if !credentials.nil? && credentials.empty?
      end

      unless credentials.nil?
        credentials = credentials.map { |k, v| [k.to_sym, v] }.to_h
        credentials[:method] = :simple unless credentials.key?(:method)
      end

      config[:auth] = credentials
      config
    end

    def credentials_from_file
      (File.exist?(CONFIG_FILENAME)) ? YAML.load_file(CONFIG_FILENAME) : nil
    end

    def rails_credentials
      if defined?(Rails.application.config_for) && File.exist?(File.join(Rails.root, 'config', CONFIG_FILENAME))
        raise "Missing cul-ldap credentials in config/#{CONFIG_FILENAME}" if Rails.application.config_for(:cul_ldap).empty?
        Rails.application.config_for(:cul_ldap)
      else
        nil
      end
    end
  end
end
