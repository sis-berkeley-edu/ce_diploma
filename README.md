# cediploma

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ce_diploma'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install ce_diploma

## Usage

### Single Sign-On (SSO)

```ruby
# configure with options
sso = CeDiploma::SingleSignOn.new(
  sso_base_url: 'https://www.example.com/',
  client_id: '123ABC0F-1B2C-9876-AF19-555566667777',
  client_number: '1234',
  mask_1: '1!2@3#4$5%6^7&8*9(0)1!2@3#4$5%6^',
  student_id: '654321')

# or dynamically
sso = CeDiploma::SingleSignOn.new
sso.enable_test_mode
sso.client_id = '123ABC0F-1B2C-9876-AF19-555566667777'
sso.client_number = '1234'
sso.mask_1 = '1!2@3#4$5%6^7&8*9(0)1!2@3#4$5%6^'
sso.student_id = '654321'

# set to link to CeDiploma test environment
sso.enable_test_mode

# or set to link to CeDiploma live environment
sso.enable_live_mode

# generate single sign on url for student id
url = sso.single_sign_on_url
```

## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then, run `rake spec` to run the tests.
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`,
which will create a git tag for the version, push git commits and tags, and push the `.gem` file
to [rubygems.org](https://rubygems.org).

### Testing

This library is tested using [Rspec](https://github.com/rspec/rspec).

To run the test suite, simply run `rspec`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sis-berkeley-edu/ce_diploma.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
