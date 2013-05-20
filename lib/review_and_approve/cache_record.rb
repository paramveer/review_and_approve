class CacheRecord < ActiveRecord::Base
  serialize :cache_data
end