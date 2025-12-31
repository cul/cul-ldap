$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "cul/ldap"
require 'rspec/its'
Dir["./spec/support/**/*.rb"].sort.each { |f| require f }

RSpec.configure do |config|
  # This allows you to limit a spec run to individual examples or groups
  # you care about by tagging them with `:focus` metadata. When nothing
  # is tagged with `:focus`, all examples get run. RSpec also provides
  # aliases for `it`, `describe`, and `context` that include `:focus`
  # metadata: `fit`, `fdescribe` and `fcontext`, respectively.
  config.filter_run_when_matching :focus
end
