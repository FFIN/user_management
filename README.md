# user_management-cookbook  [![Build Status](https://secure.travis-ci.org/FFIN/user_management.png)](http://travis-ci.org/FFIN/user_management)

User management cookbook.

With this cookbook you can

* Cerate and remove user accounts.
* Manage sudoers

## Supported Platforms

* centos
* redhat
* fedora

## Attributes

### ['user_management']['use_databag']

Define whether use data_bag for managing user accounts or not.    
**Type:** Boolean  
**Default value:** false

### ['user_management']['databag_name']

Define data\_bag name if you use data\_bag.  
**Type:** String  
**Default value:** Nil


### ['user_management']['home_dir']

Define home root directory.  
**Type:** String  
**Default value:** '/home'

### ['user_management']['default_shell']

Default shell script.  
**Type:** String  
**Default value:** '/bin/bash'


### ['user_management']['sudoer_group']

Set sudoer group.  
**Type:** Array  
**Default value:** Nil

Array element should be hash and having following set.

|Key|Value|
|---|-----|
|**:name**| Name fo the group  |
|**:sudo_pwdless**| Set this group to sudo passwordless or not  |
|**:command**| List of sudo command. |

**Example**

bellow is set admin, wheel and sysadmin groups to sudoers and
set `sysadmin` to passwordless.

```
"sudoer_group": [
  {"name" : "admin", "sudo_pwdless" : false, "command" : "ALL"},
  {"name" : "wheel", "sudo_pwdless" : false, "command" : "ALL"},
  {"name" : "sysadmin", "sudo_pwdless" : true, "command" : "ALL"}
]
```

### ['user_management']['users']

If you not use data_bag, list your users in here.

List of user accounts.  
**Type:** Array  
**Default value:** Nil

Array element should be hash and having following set.

|key|Value|
|---|-----|
|**comment**|  It's a comment...  |
|**create_home**| If you want to create users home directory or not  |
|**action**| `creat` otr `remove`  |
|**username**| Name of user  |
|**shell**| Default shell, if empty `['user_management']['default_shell']` will apply  |
|**password**| Password of user, it should be hashed.  |
|**uid**| User ID if you want to set   |
|**gid**| Group of user.  |
|**sudoer**| If you want to set this user to sudoer, set `true`  |
|**command**| List of sudo command.   |
|**sudo_pwdless**| Set this user to sudo passwordless or not  |
|**delete_home_when_remove**| If you want to delete user directory when remove this user, set `true`  |
|**ssh_keys**| Paste sshe key, if this user have one.|


**Example**

```
"users": [
  {
    "comment" : "Just a Test",
    "create_home" : true,
    "action" : "create",
    "username" : "jonedoe",
    "shell" : "/bin/bash",
    "password" : "openssl passwd -1 'plaintextpassword' goes here",
    "uid" : 1001,
    "gid" : "guest",
    "sudoer" : true,
    "sudo_pwdless" : true,
    "delete\_home\_when_remove" : true,
    "ssh_keys": "ssh-rsa ssh-keys-goes-here"
  }
]
```

#### Data bag use

If you wish to use data_bag, format of user lists is same as above,
but replace `username` key to `id`

Example

```
"users": [
  {
    "comment" : "Just a Test",
    "create_home" : true,
    "action" : "create",
    "id" : "jonedoe",
    "shell" : "/bin/bash",
    "password" : "openssl passwd -1 'plaintextpassword' goes here",
    "uid" : 1001,
    "gid" : "guest",
    "sudoer" : true,
    "sudo_pwdless" : true,
    "delete\_home\_when_remove" : true,
    "ssh_keys": "ssh-rsa ssh-keys-goes-here"
  }
]
```

## Usage

### user_management::default

Include `user_management` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[user_management::default]"
  ]
}
```

## License and Authors

Author:: Yosuke INOUE (<inoue@fieldweb.co.jp>)

```text
Copyright:: 2015, FIELD Co., Ltd.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
