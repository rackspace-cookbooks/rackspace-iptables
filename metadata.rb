name             'rackspace_iptables'
maintainer       'Rackspace'
maintainer_email 'rackspace-cookbooks@rackspace.com'
license          'Apache 2.0'
description      'Installs/Configures rackspace_iptables'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.7.3'

supports 'centos'
supports 'debian'
supports 'rhel'
supports 'ubuntu'

depends 'apt'
depends 'yum'

depends 'chef-sugar'
