require 'chefspec'
require 'chefspec/berkshelf'
require 'rspec/expectations'

require_relative '../../../libraries/helpers'

at_exit { ChefSpec::Coverage.report! }
