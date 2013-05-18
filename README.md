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

### Setup
call `review_and_approve` in an ActiveRecord class

```ruby
class Product < ActiveRecord::Base
  review_and_approve
  attr_accessible :field1, :field2.. #Make sure attr_accessible is defined properly
end
```

Use Cancan or other authorization mechanism to define a custom ability to 'publish' the records
Make sure your controller has access to current_ability method and it returns true or false on can? :publish, @product

In your controller and views, allow the users to set the published flag on the model when you are ready to publish

#### Customizations

```ruby
review_and_approve :by => [:as_json, :to_json]
  # defaults to :by => [:as_json] 
  # list of methods whose output will be cached for delta comparisons

review_and_approve :field => :published 
  # Override the field used to track whether we are publishing or not.

review_and_approve :cache_key => Proc.new{|object, method_name| #Generate key string}
  # Override the way the gem creates a key for reading/writing to the cache
```

### Showing differences from published version
A method called `published_version` is defined on the model that provides access to cached methods as of the last published version. For example:

```ruby
  @product.published_version(:as_json)   
  # => returns the as_json hash from the last time the product was published

  # Rendering the differences
  render :partial => "review_and_approve/delta", 
    :locals => {:published => @product.published_version(:as_json),
                 :current => @product.as_json}
  # Given two hashes (before/after), this will render the changes in a table

  #styling the differences
  Check out delta.css in the gem and override the styles in your application
```

## Limitations
* only certified on Rails 3.1, ruby 1.9.2
* Will use Rails.cache to store the output of methods provided to review_and_approve. We currently assume that the cache has infinite space -i.e. the cached value is never lost
 - possibly use the database in future for storing cached values
* Currently depends on the application to call attr_accessible


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
