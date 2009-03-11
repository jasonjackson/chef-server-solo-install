#
# Author:: Joshua Timberman <joshua@opscode.com>
# Cookbook Name:: chef
# Recipe:: server
#
# Copyright 2008, OpsCode, Inc
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

include_recipe "runit"

directory "/etc/chef" do
  owner "root"
  mode 0755
end

template "/etc/chef/server.rb" do
  owner "root"
  mode 0644
  source "server.rb.erb"
  action :create
end

template "/etc/chef/client.rb" do
  owner "root"
  mode 0644
  source "client.rb.erb"
  action :create
end

gem_package "stompserver" do
  action :install
end
runit_service "stompserver"


case node[:platform]
when "centos"
	package "ncurses-devel"
	package "openssl-devel"
	package "icu"
	package "libicu-devel"
	package "js"
	package "js-devel"
	package "curl-devel"
	package "erlang"
	package "subversion"
	package "libtool"
	package "m4"

	bash "install_couchdb" do
		user "root"
 		cwd "/tmp"
  		code <<-EOH 
svn checkout http://svn.apache.org/repos/asf/couchdb/trunk couchdb
cd couchdb
./bootstrap
./configure --with-erlang=/usr/lib/erlang/usr/include && make && make install

adduser -r -d /usr/local/var/lib/couchdb couchdb
chown -R couchdb /usr/local/var/lib/couchdb
chown -R couchdb /usr/local/var/log/couchdb

if [ ! -f /etc/init.d/couchdb ]; then ln -s /usr/local/etc/rc.d/couchdb /etc/init.d/couchdb; fi
EOH
	end

else
	package "couchdb"
end


directory "/var/lib/couchdb" do
  owner "couchdb"
  group "couchdb"
  recursive true
end

service "couchdb" do
  supports :restart => true, :status => true
  action [ :enable, :start ]
end

runit_service "chef-indexer" 
runit_service "chef-server"
