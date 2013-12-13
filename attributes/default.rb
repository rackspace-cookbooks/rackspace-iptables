#
# Cookbook Name:: rackspace-iptables
# Attributes:: rackspace-iptables
#
# Copyright 2013 Rackspace
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
default['rackspace-iptables']['chains']['INPUT'] = {}
default['rackspace-iptables']['chains']['OUTPUT'] = {}
default['rackspace-iptables']['chains']['FORWARD'] = {}
default['rackspace-iptables']['chains']['PREROUTING'] = {}
default['rackspace-iptables']['chains']['POSTROUTING'] = {}

