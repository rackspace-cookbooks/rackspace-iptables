require 'chefspec'
require 'chefspec/berkshelf'
require 'rspec/expectations'

# global 'node' variable for helpers
node = {}
node['name'] = 'dummy node'

require_relative '../../../libraries/helpers'

at_exit { ChefSpec::Coverage.report! }
