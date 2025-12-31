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

## Standalone Gem Usage

```
require 'cul/ldap'
ldap = Cul::LDAP.new
entry = ldap.find_by_uni("abc123")
entry = ldap.find_by_name("Doe, Jane")
```

## Rails app usage

If you're using cul-ldap in a Rails app, you can create a configuration file at config/cul_ldap.yml that looks like this:

```
development:
  host: your-ldap-server.example.com
  port: 636
  encryption: simple_tls
  auth:
    method: simple,
    username: "username", # Distinguished Name (DN)
    password: "password"
```

The configuration options here are the same ones supported by the Net::LDAP#initialize method.  Cul::LDAP is built on top of Net::LDAP.

Since this file will contain a username and password, remember to .gitignore this file in your repository.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cul/cul-ldap.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
