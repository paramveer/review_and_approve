require "review_and_approve/version"
require "review_and_approve/engine" if defined? Rails
require "review_and_approve/model_additions"
require "review_and_approve/controller_additions"
require "review_and_approve/railtie" if defined? Rails
require 'active_record'
require "review_and_approve/cache_record"
require 'review_and_approve/hash_diff'

module ReviewAndApprove

end
