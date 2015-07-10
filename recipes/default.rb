#
# Cookbook Name:: rackspace_iptables
#
# Copyright 2013 Rackspace
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

include_recipe 'chef-sugar'

case node['platform_family']
when 'debian'
  include_recipe 'apt::default'
  package 'ufw' do
    action :remove
  end
  package_name = 'iptables-persistent'
  service_name = 'iptables-persistent'
  if node['platform_version'].to_f >= 14.10
    service_name = 'netfilter-persistent'
  end

  rules_file = '/etc/iptables/rules.v4'
when 'rhel'
  package_name = nil
  package_name = 'iptables-services' if node['init_package'] == 'systemd'
  service_name = 'iptables'
  rules_file = '/etc/sysconfig/iptables'
end

service 'firewalld' do
  action %w(disable stop)
  provider Chef::Provider::Service::Systemd
  only_if { node['init_package'] == 'systemd' }
end

package package_name unless package_name.nil?

log 'run the iptables template last' do
  level :debug
  notifies :create, 'template[rules_file]', :delayed
end

template 'rules_file' do # ~FC009
  path rules_file
  cookbook node['rackspace_iptables']['templates_cookbook']['rules']
  source 'iptables.rules.erb'
  owner 'root'
  group 'root'
  mode '0600'
  helpers ::RackspaceIptables::TemplateHelpers
  variables lazy {
    {
      tables: {
        filter:   node['rackspace_iptables']['v4']['filter'],
        nat:      node['rackspace_iptables']['v4']['nat'],
        mangle:   node['rackspace_iptables']['v4']['mangle'],
        raw:      node['rackspace_iptables']['v4']['raw'],
        security: node['rackspace_iptables']['v4']['security']
      }
    }
  }

  notifies :restart, "service[#{service_name}]"
end

service service_name do
  supports status: true, restart: true
  provider Chef::Provider::Service::Systemd if node['init_package'] == 'systemd'
  status_command "iptables -L | egrep -v '^(Chain|target|$)'" if node['platform_family'] == 'debian'
  action :start
end
