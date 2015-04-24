require_relative '../spec_helper'

describe 'user_management::default' do

	before do
		stub_command("which sudo").and_return(false)
		stub_command("grep ^guest /etc/group").and_return(false)
	end

	context "with node" do
		let( :chef_run ) do
			chef_run = ChefSpec::SoloRunner.new(step_into: ['user_management']) do |node|
				node.set['user_management']['use_databag'] = false
				node.set['user_management']['home_dir'] = '/home'
				node.set['user_management']['default_shell'] = '/bin/bash'
				node.set['user_management']['sudoer_group'] = [
					{:name => "admin", :sudo_pwdless => false, :command => "ALL"},
					{:name => "wheel", :sudo_pwdless => false, :command => "ALL"},
					{:name => "sysadmin", :sudo_pwdless => true, :command => "ALL"}
				]
				node.set['user_management']['users'] = [
					{
						'comment' => 'Just a Test',
						'create_home' => true,
						'action' => 'create',
						'username' => 'testadmin',
						'shell' => '/bin/bash',
						'password' => '$1$HbBQwOLq$x5/QjzN9X0Mq6J0Q0iSXx/',
						'uid' => 1001,
						'gid' => 'guest',
						'sudoer' => true,
						'sudo_pwdless' => true,
						'delete_home_when_remove' => true,
						'ssh_keys' => 'ssh-rsa JustATestKey'
					},
					{
						'comment' => 'Remove a Bad User',
						'action' => 'remove',
						'username' => 'baduser',
						'delete_home_when_remove' => true
					}
				]
			end.converge(described_recipe)
		end

		before do
			stub_data_bag('user_management').and_return([])
		end

		it 'should creat a user' do
			expect(chef_run).to create_usermsg('testadmin')
			expect(chef_run).to create_user('testadmin').with({
				uid: 1001,
				gid: 'guest'
			})
		end

		it 'should create a group guest' do
			expect(chef_run).to create_group('guest')
		end

		it 'should installs package sudo' do
			expect(chef_run).to install_package('sudo')
		end

		it 'should testadmin to the sudoers file' do
			expect(chef_run).to render_file('/etc/sudoers').with_content(/^testadmin/)
		end

		it 'adds sudoer_group to the sudoers file' do
			expect(chef_run).to render_file('/etc/sudoers').with_content('%admin ALL=(ALL) ALL')
			expect(chef_run).to render_file('/etc/sudoers').with_content('%wheel ALL=(ALL) ALL')
			expect(chef_run).to render_file('/etc/sudoers').with_content('%sysadmin ALL=(ALL) NOPASSWD:ALL')
		end

		it 'creates the testadmin home dir' do
  			expect(chef_run).to create_directory('/home/testadmin')
  		end

		it 'creates the template with the correct attributes' do
  			expect(chef_run).to create_template('/home/testadmin/.ssh/authorized_keys')
  		end

		it 'should ssh-rsa JustATestKey to the authorized_keys file' do
			expect(chef_run).to create_directory('/home/testadmin/.ssh')
			expect(chef_run).to render_file('/home/testadmin/.ssh/authorized_keys').with_content(/^ssh-rsa JustATestKey/)
		end

		it 'should remove a bad user' do
			expect(chef_run).to remove_usermsg('baduser')
			expect(chef_run).to remove_user('baduser')
		end

		it 'should remove group baduser' do
			expect(chef_run).to remove_group('baduser')
		end

		it 'should remove a bad user directory' do
			expect(chef_run).to delete_directory('/home/baduser')
		end

	end

	context "with data_bag" do
		let( :chef_run ) do
			chef_run = ChefSpec::SoloRunner.new(step_into: ['user_management']) do |node|
				node.set['user_management']['use_databag'] = true
				node.set['user_management']['databag_name'] = 'user_management'
				node.set['user_management']['home_dir'] = '/home'
				node.set['user_management']['default_shell'] = '/bin/bash'
				node.set['user_management']['sudoer_group'] = [
					{:name => "admin", :sudo_pwdless => false, :command => "ALL"},
					{:name => "wheel", :sudo_pwdless => false, :command => "ALL"},
					{:name => "sysadmin", :sudo_pwdless => true, :command => "ALL"}
				]
				node.set['user_management']['users'] = []
			end.converge(described_recipe)
		end

		before do
			stub_data_bag('user_management').and_return(['testadmin','baduser'])
			stub_data_bag_item('user_management', 'testadmin').and_return(
				{
					'comment' => 'Just a Test',
					'create_home' => true,
					'action' => 'create',
					'id' => 'testadmin',
					'shell' => '/bin/bash',
					'password' => '$1$HbBQwOLq$x5/QjzN9X0Mq6J0Q0iSXx/',
					'uid' => 1001,
					'gid' => 'guest',
					'sudoer' => true,
					'sudo_pwdless' => true,
					'delete_home_when_remove' => true,
					'ssh_keys' => 'ssh-rsa JustATestKey'
				}
			)
			stub_data_bag_item('user_management', 'baduser').and_return(
				{
					'comment' => 'Remove a Bad User',
					'action' => 'remove',
					'id' => 'baduser',
					'delete_home_when_remove' => true
				}
			)
		end

		it 'should creat a user' do
			expect(chef_run).to create_usermsg('testadmin')
			expect(chef_run).to create_user('testadmin').with({
				uid: 1001,
				gid: 'guest'
			})
		end

		it 'should create a group guest' do
			expect(chef_run).to create_group('guest')
		end

		it 'should installs package sudo' do
			expect(chef_run).to install_package('sudo')
		end

		it 'should testadmin to the sudoers file' do
			expect(chef_run).to render_file('/etc/sudoers').with_content(/^testadmin/)
		end

		it 'adds sudoer_group to the sudoers file' do
			expect(chef_run).to render_file('/etc/sudoers').with_content('%admin ALL=(ALL) ALL')
			expect(chef_run).to render_file('/etc/sudoers').with_content('%wheel ALL=(ALL) ALL')
			expect(chef_run).to render_file('/etc/sudoers').with_content('%sysadmin ALL=(ALL) NOPASSWD:ALL')
		end

		it 'creates the testadmin home dir' do
  			expect(chef_run).to create_directory('/home/testadmin')
  		end

		it 'creates the template with the correct attributes' do
  			expect(chef_run).to create_template('/home/testadmin/.ssh/authorized_keys')
  		end

		it 'should ssh-rsa JustATestKey to the authorized_keys file' do
			expect(chef_run).to create_directory('/home/testadmin/.ssh')
			expect(chef_run).to render_file('/home/testadmin/.ssh/authorized_keys')
		end

		it 'should remove a bad user' do
			expect(chef_run).to remove_usermsg('baduser')
			expect(chef_run).to remove_user('baduser')
		end

		it 'should remove group baduser' do
			expect(chef_run).to remove_group('baduser')
		end

		it 'should remove a bad user directory' do
			expect(chef_run).to delete_directory('/home/baduser')
		end

	end

	
end