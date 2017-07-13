$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "cul/ldap"
require 'rspec/its'
Dir["./spec/support/**/*.rb"].sort.each { |f| require f }
