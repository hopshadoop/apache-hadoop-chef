#include_recipe "hadoop::install"


# TODO - if multiple RMs, and node[:yarn][:rm][:addrs] is set because
# RMs are in different node groups, then use the attribute. Else
# use the private_ips

rm_ip = private_recipe_ip("hadoop","rm")
my_ip = my_private_ip()
Chef::Log.info "Resourcemanager IP: #{rm_ip}"

#total_mem = node['memory']['total'].split('kB')[0].to_i / 1024
#available_mem = (total_mem > 500) ? total_mem - 500 : total_mem

template "#{node[:hadoop][:home]}/etc/hadoop/yarn-site.xml" do
  source "yarn-site.xml.erb"
  owner node[:hadoop][:yarn][:user]
  group node[:hadoop][:group]
  mode "666"
  variables({
              :rm_ip => rm_ip,
              :my_ip => my_ip,
              :available_mem_mb => node[:hadoop][:yarn][:nm][:memory_mbs]
            })
  action :create_if_missing
#  notifies :restart, resources(:service => "rm")
end

template "#{node[:hadoop][:home]}/etc/hadoop/mapred-site.xml" do
  source "mapred-site.xml.erb"
  owner node[:hadoop][:mr][:user]
  group node[:hadoop][:group]
  mode "666"
  variables({
              :rm_ip => rm_ip
            })
#  notifies :restart, resources(:service => "jhs")
end

template "#{node[:hadoop][:home]}/etc/hadoop/capacity-scheduler.xml" do
  source "capacity-scheduler.xml.erb"
  owner node[:hadoop][:yarn][:user]
  group node[:hadoop][:group]
  mode "666"
  variables({
              :rm_ip => rm_ip
            })
 # notifies :restart, resources(:service => "jhs")
end
