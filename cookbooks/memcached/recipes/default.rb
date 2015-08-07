require 'pp'
#
# Cookbook Name:: memcached
# Recipe:: default
#

server_name = ""
node[:utility_instances].each do |instance|
 server_name = instance[:hostname] if instance[:name] == 'memcached'
end

node[:applications].each do |app_name,data|
  user = node[:users].first
  
case @node[:instance_role]     when  "app_master",  "app"
 ##  when  'app', 'app_master', 'solo'
 ## when  "app_master", "app"
 template "/data/#{app_name}/shared/config/memcached_custom.yml" do
     source "memcached.yml.erb"
     owner user[:username]
     group user[:username]
     mode 0744
     variables({
         :app_name => app_name,
         :server_name => server_name
     })
   end
  end

  
if node[:name] == 'memcached'   
   
   template "/etc/conf.d/memcached" do
     owner 'root'
     group 'root'
     mode 0644
     source "memcached.erb"
     variables :memusage => 564,
               :port     => 11211
   end

## Start memcached service on system boot ##   
   execute "enable memcached" do
  command "rc-update add memcached default"
  action :run
end

execute "start memcached" do
  command "/etc/init.d/memcached restart"
  action :run
  not_if "/etc/init.d/memcached status"
end
  
	end  
end