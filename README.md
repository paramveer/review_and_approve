# ReviewAndApprove

Add functionality in a content based app to explicitly review and approve all data changes before they are visible to end users.

## Installation

Add this line to your application's Gemfile:

    gem 'review_and_approve'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install review_and_approve

To install the database schema

    $ rails g review_and_approve:install
    $ bundle exec rake db:migrate

## Usage

### Setup
call `review_and_approve` in an ActiveRecord class

```ruby
class Product < ActiveRecord::Base
  review_and_approve
  attr_accessible :field1, :field2.. #Make sure attr_accessible is defined properly
end
```

In your form.html.erb 
```ruby
  <div class="field">
    <%= f.check_box :publish %>
    <%= f.label :publish %>
  </div>
```

To mark existing data as published:

    $ bundle exec rake review_and_approve:create_caches 
      # => Marks all records of all classes using review_and_approve as published
    $ bundle exec rake review_and_approve:create_caches[Product, AnotherClass]
      # => Only mark the records for listed classes

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
Methods called `published_version` and `current_version` are defined on the model that provides access to cached methods as of the last published or current versions. For example:

```ruby
  @product.published_version(:as_json)   
  # => returns the as_json hash from the last time the product was published

  @product.current_version(:as_json)
  # => returns the as_json hash for the current iteration. It is advisable to use this to avoid getting bogged down by changes to date/time and other fields because of just saving and retrieving from your cache(i.e. database)

  # Rendering the differences
  render :partial => "review_and_approve/delta", 
    :locals => {:published => @product.published_version(:as_json),
                 :current => @product.current_version(:as_json)}
  # Given two hashes (before/after), this will render the changes in a table

  #styling the differences
  Include review_and_approve/application in your application.css or
  check out delta.css in the gem and override the styles in your application
```

## Limitations and Warnings
* only certified on Rails 3.1, ruby 1.9.2
* Currently depends on the application to set up attr_accessible properly, else all mass-assignment would be disabled (You *should* have attr_accessible set up on rails 3.x anyway)


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Run all tests to confirm they pass (`bundle exec rake`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request
