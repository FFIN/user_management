name             'user_management'
maintainer       'Yosuke INOUE'
maintainer_email 'inoue@fieldweb.co.jp'
license          'Apache 2.0'
description      'Installs/Configures user accounts'
version          '1.0.1'

%w{ centos redhat fedora }.each do |os|
  supports os
end
