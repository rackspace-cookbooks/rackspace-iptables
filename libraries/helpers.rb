#
# Cookbook Name:: rackspace_iptables
# Library:: helpers
#
# Copyright 2014, Rackspace, US Inc.
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
module RackspaceIptables
  # convenience functions for building iptables rules in Rolebooks
  module Helpers
    # find servers to/from which to configure access
    def add_iptables_rule(chain, rule, weight = 50, comment = nil)
      rule_node = node.default['rackspace_iptables']['config']['chains'][chain][rule]

      rule_node['weight'] = weight
      rule_node['comment'] = comment if comment
    end

    def search_add_iptables_rules(search_str, chain, rules_to_add, weight = 50, comment = search_str) # rubocop:disable Metrics/AbcSize
      if Chef::Config['solo']
        Chef::Log.warn 'Running Chef Solo; doing nothing for function call to add_rules_for_nodes'
      else
        search_str = search_str << " AND NOT name:#{node.name}"
        nodes = search('node', search_str) || []

        rules = convert_nodes_to_rules(nodes, rules_to_add, weight, comment)
        rules.each { |rule, val| node.default['rackspace_iptables']['config']['chains'][chain][rule] = val }
      end
    end

    def self.convert_nodes_to_rules(nodes, rules_to_add, weight, comment)
      require 'chef/sugar'

      rules = {}
      nodes.each do |member|
        server_ip = Chef::Sugar::IP.best_ip_for(current_node, member)

        unless member && server_ip
          Chef::Log.warn("Could not determine a valid ip for #{member}, skipping search_add_iptables_rules for this node")
          next
        end

        # when passing a single rule, user may use a string instead of an array
        rules_to_add = [rules_to_add] if rules_to_add.class == String
        rules_to_add.each do |rule|
          rules["-s #{server_ip}/32 " << rule] = { comment: comment, weight: weight }
        end
      end

      rules
    end

    # allow us to inject a node when this is run outside a chef run_context
    # - this is not really a trivial accessor b/c it's called externally for tests
    def self.mock_current_node(value) # rubocop:disable TrivialAccessors
      @mock_current_node = value
    end

    # look for the built-in node object from chef, or fall back to @node member
    # for testing scenarios with dummy node data
    def self.current_node
      node
    rescue
      @mock_current_node
    end
  end
end

Chef::Recipe.send(:include, ::RackspaceIptables::Helpers)
Chef::Resource.send(:include, ::RackspaceIptables::Helpers)
Chef::Provider.send(:include, ::RackspaceIptables::Helpers)
