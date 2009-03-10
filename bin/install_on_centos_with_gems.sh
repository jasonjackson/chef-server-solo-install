#!/bin/bash
wget http://source.collectiveidea.com/pub/linux/centos/4/i386/ci.repo -O /etc/yum.repos.d/ci.repo
rpm -Uvh http://download.fedora.redhat.com/pub/epel/5/i386/epel-release-5-3.noarch.rpm

yum install -y ruby rubygems

wget http://rubyworks.rubyforge.org/RubyWorks.repo -O /etc/yum.repos.d/RubyWorks.repo

yum install -y ruby gcc gcc-c++ ruby-devel ruby-docs ruby-ri ruby-irb ruby-rdoc

gem sources -d http://rubyworks.rubyforge.org/redhat/5/GEMS/i386/
gem sources -a http://gems.rubyforge.org

cd /tmp
wget http://rubyforge.org/frs/download.php/45904/rubygems-update-1.3.1.gem
gem install rubygems-update
update_rubygems

gem sources -a http://gems.opscode.com
gem install chef ohai chef-server

mkdir /etc/chef

cat > /etc/chef/solo.rb <<- EOL
#
# Chef Solo Config File
#
log_level          :info
log_location       STDOUT
file_cache_path    "/tmp/chef-solo"
cookbook_path      "/tmp/chef-solo/cookbooks"
Chef::Log::Formatter.show_time = false
EOL 

chef-solo

