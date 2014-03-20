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
      node.default['rackspace_iptables']['config']['chains'][chain][rule]['weight'] = weight
      node.default['rackspace_iptables']['config']['chains'][chain][rule]['comment'] = comment if comment
    end

    def search_add_iptables_rules(search_str, chain, rules_to_add, weight = 50, comment = search_str)
      if !Chef::Config['solo']
        rules = {}
        server_ips = []
        nodes = search('node', search_str) || []
        nodes.map! do |member|
          if member.attribute?('cloud')
            if member['cloud']['provider'] == ('rackspace' || 'openstack')
              if member['cloud'].attribute?('local_ipv4')
                server_ips.push(member['cloud']['local_ipv4']) unless member['cloud']['local_ipv4'].nil?
              elsif member['cloud'].attribute?('public_ipv4')
                server_ips.push(member['cloud']['public_ipv4']) unless member['cloud']['public_ipv4'].nil?
              end
            end
          elsif
            if member.attribute?('ipaddress')
              server_ips.push(member['ipaddress']) unless member['ipaddress'].nil?
            end
          end
          # when passing a single rule, user may use a string instead of an array
          rules_to_add = [rules_to_add] if rules_to_add.class == String
          rules_to_add.each do |rule|
            server_ips.each do |server_ip|
              rules["-s #{server_ip}/32 " << rule] = { comment: comment, weight: weight }
            end
          end
        end
        rules.each { |rule, val| node.default['rackspace_iptables']['config']['chains'][chain][rule] = val }
      else
        Chef::Log.warn 'Running Chef Solo; doing nothing for function call to add_rules_for_nodes'
      end
    end
  end
end

Chef::Recipe.send(:include, ::RackspaceIptables::Helpers)
Chef::Resource.send(:include, ::RackspaceIptables::Helpers)
Chef::Provider.send(:include, ::RackspaceIptables::Helpers)
