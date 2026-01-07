require "net/ldap"
require "yaml"

require "cul/ldap/version"
require "cul/ldap/exceptions"
require "cul/ldap/entry"

module Cul
  class LDAP < Net::LDAP
    CONFIG_FILENAME = 'cul_ldap.yml'
    CONFIG_DEFAULTS = {
      encryption: {
        method: :simple_tls,
        tls_options: OpenSSL::SSL::SSLContext::DEFAULT_PARAMS
      },
    }.freeze
    REQUIRED_OPTS = [ :host, :port, :auth ].freeze
    REQUIRED_AUTH_OPTS = [ :method, :username, :password ].freeze

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
      search_res = super(args).tap do |result|
        if result.is_a?(Array)
          result.map!{ |e| Cul::LDAP::Entry.new(e) }
        end
      end

      # If a username and password were provided, the query will return a result no matter what. Check if auth failed:
      check_operation_result

      search_res
    end

    # Checks for some common error cases that the user can easily remidy (all auth errors)
    # For all LDAP operation result codes and their meanings: https://ldap.com/ldap-result-code-reference/
    def check_operation_result
      operation_result = get_operation_result
      if [49, 50, 53].include? operation_result.code
        raise Exceptions::AuthError, "LDAP Error: (code #{operation_result.code}) '#{operation_result.error_message}' Make sure you provide a proper username and password for authentication."
      end
    end

    private

    def build_config(options)
      config = CONFIG_DEFAULTS.dup

      # If a cul_ldap.yml config file is found, merge in those settings first
      options_from_config_file = options_from_rails_config || options_from_file_config

      config = config.merge(options_from_config_file) if options_from_config_file

      # Then merge in any settings supplies by options
      config = config.merge(options) if options

      # If auth method has been supplied as a string, convert it to a symbol
      config[:auth][:method] = :simple if config[:auth] && config.dig(:auth, :method) == 'simple'
      
      # If any required information is missing from the options, raise an error
      validate_config(config)

      config
    end

    def options_from_file_config
      (File.exist?(CONFIG_FILENAME)) ? YAML.load_file(CONFIG_FILENAME) : nil
    end

    def options_from_rails_config
      if defined?(Rails.application.config_for) && File.exist?(File.join(Rails.root, 'config', CONFIG_FILENAME))
        if Rails.application.config_for(CONFIG_FILENAME.gsub(/.yml$/, '').to_sym).empty?
          raise "Missing cul-ldap configuration in config/#{CONFIG_FILENAME}"
        end
        Rails.application.config_for(:cul_ldap)
      else
        nil
      end
    end

    def validate_config(config)
      REQUIRED_OPTS.each do |opt|
        raise Exceptions::InvalidOptionError, "Missing required cul-ldap configuration option: #{opt}" unless config.has_key? opt
      end
      
      # Validate nested auth options
      REQUIRED_AUTH_OPTS.each do |auth_opt|
        raise Exceptions::InvalidOptionError, "Missing required cul-ldap configuration option: :auth=> { #{auth_opt} }" unless config[:auth].has_key? auth_opt
      end
    end
  end
end
