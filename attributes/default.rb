#
# Author:: Yosuke Inoue (<inoue@fieldweb.co.jp>)
# Cookbook Name:: user_management
# Attribute:: default
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

default['user_management']['home_root'] = '/home'
default['user_management']['default_shell'] = '/bin/bash'
default['user_management']['use_databag'] = false
default['user_management']['databag_name'] = 'user_management'