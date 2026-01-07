# Cul::LDAP

Gem for CUL's common queries to CU's LDAP server. This is just a starting point with one query that is commonly needed. Needs some work to build out new functionality. Uses net-ldap to make queries. Cul::LDAP could be delegated to Net::LDAP if more functionality like the one already implemented there is required.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cul-ldap'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cul-ldap

## Usage

Users must provide a full configuration including the cul LDAP server host, port, and auth credentials. This can be done by passing a hash object to the class initializer, or by including a `cul_ldap.yml` file.

The configuration options here are the same ones supported by the Net::LDAP#initialize method.  Cul::LDAP is built on top of Net::LDAP. [See the Net::LDAP#initialize documentation here](https://www.rubydoc.info/gems/ruby-net-ldap/Net/LDAP#initialize-instance_method).


Since this file will contain a username and password, remember to .gitignore this file in your repository.

```
host: 'servername'                   # Required.
port: 636                                   # Required. Standard port for simple-tls encrypted ldap connections.
encryption: simple_tls
auth:                                       # Required (all fields).
    method: simple
    username: "USERNAME"
    password: "PASSWORD"
```

**❗You can use the information in [this confluence page](https://columbiauniversitylibraries.atlassian.net/wiki/spaces/USGSERVICES/pages/10947594/LDAP+Lookup+including+affiliations+via+privileged+lookup#Using-a-secure-%E2%80%9Cldaps%3A%2F%2F%E2%80%9D-connection-(recommended)%3A) to fill out the username and password credentials here.❗**

### Usage in Rails
If you are using this gem in a rails context, we recommend creating a `config/cul_ldap.yml` file with your desired configuration. It will be read by the gem automatically.

### Standalone Gem Usage

```
require 'cul/ldap'
ldap = Cul::LDAP.new                        # Assuming you have a proper cul_ldap.yml file
entry = ldap.find_by_uni("abc123")
entry = ldap.find_by_name("Doe, Jane")
```

### Rails app usage

If you're using cul-ldap in a Rails app, you can create a configuration file at `config/cul_ldap.yml` that looks the one at the top of this section.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cul/cul-ldap.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
