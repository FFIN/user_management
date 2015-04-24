actions :create, :remove
default_action :create

attribute :username, kind_of: String, name_attribute: true
attribute :comment, kind_of: String
attribute :groups, kind_of: Array
attribute :gid, kind_of: [Integer, String]
attribute :create_home, kind_of: [TrueClass, FalseClass], default: true
attribute :uid, kind_of: [Integer, String]
attribute :ssh_keys, kind_of: [String, Array]
attribute :shell, kind_of: String
attribute :password, kind_of: String
attribute :delete_home_when_remove, kind_of: [TrueClass, FalseClass], default: true
