rackspace_iptables cookbook CHANGELOG
======================
This file is used to list changes made in each version of the rackspace_iptables cookbook.

v1.7.1
------
- Emergency fix, typo node/current_node.

v1.7.0
------
- Release to get us back in sync from v1.6.0.

v1.6.0
------
- Due to a release to Supermarket without source, this version is deprecated.

v1.5.0
------
- Change search_add_iptables_rules syntax to make it chef-zero compatible

v1.3.1
------
- Fix the ordering issue in runlists
- fix apt not beging initialized on first run

v1.3.0
------
- Do not inculde the local node in the search results

v1.2.0
------
- Add helper functions add_iptables_rule and search_add_iptables_rules
- Add Chefspec 3 and Test Kitchen 1.1.1 tests
- Rubocop and Foodcritic pass
- Add documentation to README
