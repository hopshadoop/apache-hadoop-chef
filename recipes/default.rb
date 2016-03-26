# Cookbook Name:: apache_hadoop
# Recipe:: default
# All rights reserved - Do Not Redistribute
#

my_ip = my_private_ip()
my_public_ip = my_public_ip()

firstNN = private_recipe_ip("apache_hadoop", "nn") + ":#{node.apache_hadoop.nn.port}"
Chef::Log.info "NameNode private IP: #{firstNN}"

rm_private_ip = private_recipe_ip("apache_hadoop","rm")
Chef::Log.info "Resourcemanager IP: #{rm_private_ip}"

rm_public_ip = public_recipe_ip("apache_hadoop","rm")
Chef::Log.info "Resourcemanager IP: #{rm_public_ip}"

ha_enabled = false
if node.apache_hadoop.ha_enabled.eql? "true" || node.apache_hadoop.ha_enabled == true
  ha_enabled = true
end


template "#{node.apache_hadoop.home}/etc/hadoop/core-site.xml" do 
  source "core-site.xml.erb"
  owner node.apache_hadoop.hdfs.user
  group node.apache_hadoop.group
  mode "755"
  variables({
              :myNN => "hdfs://" + firstNN
            })
  action :create_if_missing
end

journal_urls=""
zk_nodes=""
if ha_enabled == true
  journal_urls="qjournal://" + node.apache_hadoop.jn.private_ips.join(":8485;") + ":8485"
  zk_nodes=node.kzookeeper.default.private_ips.join(":2181,") + ":2181"
end



secondNN = ""

if node.apache_hadoop.nn.private_ips.length > 1
   secondNN = "#{node.apache_hadoop.nn.private_ips[1]}" + ":#{node.apache_hadoop.nn.port}"
end

template "#{node.apache_hadoop.home}/etc/hadoop/hdfs-site.xml" do
     case ha_enabled
     when true
  source "hdfs-site-ha.xml.erb"
     when false
  source "hdfs-site.xml.erb"
     end
  owner node.apache_hadoop.hdfs.user
  group node.apache_hadoop.group
  mode "755"
  variables({
              :firstNN => firstNN,
              :secondNN => secondNN,
              :addr1 => my_ip + ":40100",
              :addr2 => my_ip + ":40101",
              :addr3 => my_ip + ":40102",
              :addr4 => my_ip + ":40103",
              :addr5 => my_ip + ":40104",
              :journal_urls => journal_urls,
              :zk_nodes => zk_nodes
            })
  action :create_if_missing
end

template "#{node.apache_hadoop.home}/etc/hadoop/hadoop-env.sh" do
  source "hadoop-env.sh.erb"
  owner node.apache_hadoop.hdfs.user
  group node.apache_hadoop.group
  mode "755"
end


template "#{node.apache_hadoop.home}/etc/hadoop/jmxremote.password" do 
  source "jmxremote.password.erb"
  owner node.apache_hadoop.hdfs.user
  group node.apache_hadoop.group
  mode "600"
end

template "#{node.apache_hadoop.home}/etc/hadoop/yarn-jmxremote.password" do 
  source "jmxremote.password.erb"
  owner node.apache_hadoop.yarn.user
  group node.apache_hadoop.group
  mode "600"
end


template "#{node.apache_hadoop.home}/sbin/kill-process.sh" do 
  source "kill-process.sh.erb"
  owner node.apache_hadoop.hdfs.user
  group node.apache_hadoop.group
  mode "754"
end

template "#{node.apache_hadoop.home}/sbin/set-env.sh" do 
  source "set-env.sh.erb"
  owner node.apache_hadoop.hdfs.user
  group node.apache_hadoop.group
  mode "774"
end


l = node.apache_hadoop.nn.private_ips.length
last=node.apache_hadoop.nn.private_ips[l-1]
first=node.apache_hadoop.nn.private_ips[0]

if node.apache_hadoop.install_protobuf == "true"
  proto_url = node.apache_hadoop.protobuf.url
  Chef::Log.info "Downloading hadoop binaries from #{proto_url}"
  proto = File.basename(proto_url)
  proto_filename = "#{Chef::Config.file_cache_path}/#{proto}"

  remote_file proto_filename do
    source proto_url
    owner node.apache_hadoop.hdfs.user
    group node.apache_hadoop.group
    mode "0755"
    # TODO - checksum
    action :create_if_missing
  end

  bash "install_protobuf_2_5" do
    user node.apache_hadoop.hdfs.user
    code <<-EOF
    apt-get -y remove protobuf-compiler
    tar -xzf #{proto_filename} -C #{Chef::Config.file_cache_path}
    cd #{Chef::Config.file_cache_path}/protobuf-2.5.0
    ./configure --prefix=/usr
    make
    make install
    protoc --version
    EOF
    not_if { "protoc --version | grep 2\.5" }
  end
end


if "#{node.apache_hadoop.user_envs}".eql? "true"
  apache_hadoop_user_envs node.apache_hadoop.hdfs.user do
    action :update
  end

  apache_hadoop_user_envs node.apache_hadoop.yarn.user do
    action :update
  end

  apache_hadoop_user_envs node.apache_hadoop.mr.user do
    action :update
  end
end

directory "/conf" do
  owner "root"
  group node.apache_hadoop.group
  mode "0755"
  recursive true
  action :create
end


directory "#{node.apache_hadoop.home}/journal" do
  owner node.apache_hadoop.hdfs.user
  group node.apache_hadoop.group
  mode "0755"
  recursive true
  action :create
end

template "/conf/container-executor.cfg" do
  source "container-executor.cfg.erb"
  owner node.apache_hadoop.hdfs.user
  group node.apache_hadoop.group
  mode "755"
end


container_executor="org.apache.hadoop.yarn.server.nodemanager.DefaultContainerExecutor"
if node.apache_hadoop.cgroups.eql? "true" 
  container_executor="org.apache.hadoop.yarn.server.nodemanager.LinuxContainerExecutor"
end


unless node.apache_hadoop.yarn.key?('nm.memory_mbs')
  mem = (node.memory.total.to_i / 1000)
  if node.apache_hadoop.key?('yarn') && node.apache_hadoop.yarn.key?('memory_percent')
    pct = (node.apache_hadoop.yarn.memory_percent.to_f / 100)
  else
    pct = 0.50
  end
  node.override.apache_hadoop.yarn.nm.memory_mbs = (mem * pct).to_i
end

rm_dest_ip = rm_private_ip

file "#{node.apache_hadoop.home}/etc/hadoop/yarn-site.xml" do 
  owner node.apache_hadoop.yarn.user
  action :delete
end

template "#{node.apache_hadoop.home}/etc/hadoop/yarn-site.xml" do
  source "yarn-site.xml.erb"
  owner node.apache_hadoop.yarn.user
  group node.apache_hadoop.group
  mode "666"
  variables({
              :rm_private_ip => rm_dest_ip,
              :rm_public_ip => rm_public_ip,
              :available_mem_mb => node.apache_hadoop.yarn.nm.memory_mbs,
              :my_public_ip => my_public_ip,
              :my_private_ip => my_ip,
              :container_executor => container_executor
            })
  action :create_if_missing
#  notifies :restart, resources(:service => "rm")
end

file "#{node.apache_hadoop.home}/etc/hadoop/mapred-site.xml" do 
  owner node.apache_hadoop.mr.user
  action :delete
end

template "#{node.apache_hadoop.home}/etc/hadoop/mapred-site.xml" do
  source "mapred-site.xml.erb"
  owner node.apache_hadoop.mr.user
  group node.apache_hadoop.group
  mode "666"
  variables({
              :rm_private_ip => rm_private_ip
            })
#  notifies :restart, resources(:service => "jhs")
end

file "#{node.apache_hadoop.home}/etc/hadoop/capacity-scheduler.xml" do 
  owner node.apache_hadoop.yarn.user
  action :delete
end

template "#{node.apache_hadoop.home}/etc/hadoop/capacity-scheduler.xml" do
  source "capacity-scheduler.xml.erb"
  owner node.apache_hadoop.yarn.user
  group node.apache_hadoop.group     
  mode "666"
  variables({
              :rm_ip => rm_private_ip
            })
 # notifies :restart, resources(:service => "jhs")
end
