require 'review_and_approve'
require 'supermodel'
require 'rails'
require 'cancan/ability'
require 'cancan/rule'
require 'debugger'
require 'mocha/api'


RSpec.configure do |config|
  config.mock_framework = :mocha
end