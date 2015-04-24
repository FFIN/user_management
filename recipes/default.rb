#
# Author:: Yosuke Inoue (<inoue@fieldweb.co.jp>)
# Cookbook Name:: user_management
# Recipe:: default
#
# Copyright 2015, FIELD Co., Ltd.
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

package 'sudo' do
  action :install
  not_if 'which sudo'
end

if node['user_management']['use_databag'] == true then
	users = data_bag(node['user_management']['databag_name'])
	sudoer_users = Array.new()
	users.each do |id|
		user = data_bag_item(node['user_management']['databag_name'], id)
		user_management user['id'] do
			comment user['comment'] unless user['comment'].nil?
			create_home user['create_home']
			shell user['shell'] unless user['shell'].nil?
			password user['password'] unless user['password'].nil?
			uid user['uid'] unless user['uid'].nil?
			gid user['gid'] unless user['gid'].nil?
			ssh_keys user['ssh_keys'] unless user['ssh_keys'].nil?
			delete_home_when_remove user['delete_home_when_remove'] unless user['delete_home_when_remove'].nil?
			if user['action'] == 'remove' then
				action :remove
			else
				action :create
			end
		end
		if user['sudoer']
			command = user['command'] ? user['command'] : 'ALL'
			hash = { :uname => user['id'], :command => command, :sudo_pwdless => user['sudo_pwdless'] }
			sudoer_users.push(hash)
		end
	end
else
	sudoer_users = Array.new()
	node['user_management']['users'].each do |user|
	    user_management user['username'] do
			comment user['comment'] unless user['comment'].nil?
			create_home user['create_home']
			shell user['shell'] unless user['shell'].nil?
			password user['password'] unless user['password'].nil?
			uid user['uid'] unless user['uid'].nil?
			gid user['gid'] unless user['gid'].nil?
			ssh_keys user['ssh_keys'] unless user['ssh_keys'].nil?
			delete_home_when_remove user['delete_home_when_remove'] unless user['delete_home_when_remove'].nil?
			if user['action'] == 'remove' then
				action :remove
			else
				action :create
			end
		end
		if user['sudoer']
			command = user['command'] ? user['command'] : 'ALL'
			hash = { :uname => user['username'], :command => command, :sudo_pwdless => user['sudo_pwdless'] }
			sudoer_users.push(hash)
		end
	end
end

template "/etc/sudoers" do
	source 'sudoers.erb'
	mode   '0440'
	owner  'root'
	group  node['root_group']
	variables(
		:sudoers_users     => sudoer_users,
		:sudoers_groups     => node['user_management']['sudoer_group']
	)
	only_if { sudoer_users }
end
