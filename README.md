# ReviewAndApprove

Add functionality in a content based app to explicitly review and approve all data changes before they are visible to end users.

## Installation

Add this line to your application's Gemfile:

    gem 'review_and_approve'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install review_and_approve

## Usage

call `review_and_approve` in an ActiveRecord class

```ruby
class Product < ActiveRecord::Base
  review_and_approve :by => [:as_json, :to_json] #defaults to :by => [:as_json] - list of methods whose output will be cached for delta comparisons
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
