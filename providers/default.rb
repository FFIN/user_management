action :create do
 
  # group new_resource.username do
  #   gid new_resource.uid unless new_resource.uid.nil?
  #   action :create
  #   only_if { new_resource.gid.nil? }
  # end
  
  group new_resource.gid do
    check_command = "grep ^#{new_resource.gid} /etc/group";
    if(/^[0-9]+$/.match(new_resource.gid))
      check_command = "egrep \"^[^:]+:[^:]+:#{new_resource.gid}:.*\" /etc/group";
    end
    gid new_resource.uid
    action :create
    not_if check_command
  end

  groupid = new_resource.gid.nil? ? new_resource.username : new_resource.gid

  user new_resource.username do
    comment new_resource.comment
    gid groupid
    home "#{node['user_management']['home_dir']}/#{new_resource.username}"
    password new_resource.password unless new_resource.password.nil?
    shell new_resource.shell || node['user_account']['default_shell']
    uid new_resource.uid unless new_resource.uid.nil?
    action :create
  end


  directory "#{node['user_management']['home_dir']}/#{new_resource.username}" do
    action :create
    mode 0755
    owner new_resource.username
    group groupid
    only_if { new_resource.create_home }
  end

  unless ssh_keys.nil?
    directory "#{node['user_management']['home_dir']}/#{new_resource.username}/.ssh" do
      action :create
      mode 0700
      owner new_resource.username
      group groupid
    end

    template "#{node['user_management']['home_dir']}/#{new_resource.username}/.ssh/authorized_keys" do
      mode 0600
      owner new_resource.username
      group groupid
      action :create
      source 'authorized_keys.erb'
      cookbook 'user_management'
      variables(keys: ssh_keys)
    end
 end

  unless new_resource.groups.nil?
    new_resource.groups.each do |grp|
      group grp do
        append true
        members new_resource.username
      end
    end
  end
  new_resource.updated_by_last_action(true)
end


action :remove do
  usr = user new_resource.username do
    action :nothing
  end
  usr.run_action :remove

  grp = group new_resource.username do
    action :nothing
  end

  directory "#{node['user_management']['home_dir']}/#{new_resource.username}" do
    action :delete
    recursive true
    only_if { new_resource.delete_home_when_remove }
  end

  grp.run_action :remove
  new_resource.updated_by_last_action(true)
end

def ssh_keys
  if new_resource.ssh_keys.kind_of? String
    [new_resource.ssh_keys]
  else
    new_resource.ssh_keys
  end
end
