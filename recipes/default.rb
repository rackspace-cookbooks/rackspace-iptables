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
  variables lazy {
    {
      INPUT: node['rackspace_iptables']['config']['chains']['INPUT'],
      OUTPUT: node['rackspace_iptables']['config']['chains']['OUTPUT'],
      FORWARD: node['rackspace_iptables']['config']['chains']['FORWARD'],
      PREROUTING: node['rackspace_iptables']['config']['chains']['PREROUTING'],
      POSTROUTING: node['rackspace_iptables']['config']['chains']['POSTROUTING']
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
