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
  DEFAULT_WEIGHT = 50
  DEFAULT_CHAINS = %w(FORWARD INPUT OUTPUT POSTROUTING PREROUTING)
  DEFAULT_POLICY = 'ACCEPT [0:0]'

  module TemplateHelpers
    def render_chain_definitions(chains)
      chain_definitions = []

      chains.keys.sort.each do |chain|
        if DEFAULT_CHAINS.include?(chain)
          policy = chains[chain]['default'] || DEFAULT_POLICY
        else
          policy = '- [0:0]'
        end

        chain_definitions << ":#{chain} #{policy}"
      end

      chain_definitions.join("\n")
    end

    def render_table_rules(chains)
      table_rules = []

      chains.each_pair do |chain, rules|
        # reverse sort by weight first, lexically second
        sorted_rules = rules.sort_by do |k, v|
          [v['weight'] || DEFAULT_WEIGHT, k]
        end

        sorted_rules.reverse_each do |rule, opts|
          next if rule == 'default' # skip default policies

          rule = ["-A #{chain} #{rule}"]
          rule << %(-m comment --comment "#{opts['comment']}") if opts['comment']

          table_rules << rule.join(' ')
        end
      end

      table_rules.join("\n")
    end

    def render_table(name, chains)
      return if chains.nil? || chains.empty?

      table = ["*#{name}"]
      table << render_chain_definitions(chains)
      table << render_table_rules(chains)
      table << 'COMMIT'
      table << "\n"

      table.join("\n")
    end
  end

  # convenience functions for building iptables rules in Rolebooks
  module Helpers
    # find servers to/from which to configure access
    def add_iptables_rule(table, chain, rule, weight = DEFAULT_WEIGHT, comment = nil)
      rule_node = node.default['rackspace_iptables']['v4'][table][chain][rule]

      rule_node['weight'] = weight
      rule_node['comment'] = comment if comment
    end

    def search_add_iptables_rules(search_str, table, chain, rules_to_add, weight = DEFAULT_WEIGHT, comment = search_str) # rubocop:disable Metrics/AbcSize
      if Chef::Config['solo']
        Chef::Log.warn 'Running Chef Solo; doing nothing for function call to add_rules_for_nodes'
      else
        search_str = search_str << " AND NOT name:#{node.name}"
        nodes = search('node', search_str) || []

        rules = convert_nodes_to_rules(nodes, rules_to_add, weight, comment)
        rules.each { |rule, val| node.default['rackspace_iptables']['v4'][table][chain][rule] = val }
      end
    end

    def convert_nodes_to_rules(nodes, rules_to_add, weight, comment)
      require 'chef/sugar'

      rules = {}
      nodes.each do |member|
        server_ip = Chef::Sugar::IP.best_ip_for(node, member)

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
  end
end

Chef::Recipe.send(:include, ::RackspaceIptables::Helpers)
Chef::Resource.send(:include, ::RackspaceIptables::Helpers)
Chef::Provider.send(:include, ::RackspaceIptables::Helpers)
