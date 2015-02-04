# Cookbook Name:: hadoop
# Recipe:: default
# All rights reserved - Do Not Redistribute
#

libpath = File.expand_path '../../../kagent/libraries', __FILE__
require File.join(libpath, 'inifile')

my_ip = my_private_ip()

firstNN = "hdfs://" + private_recipe_ip("hadoop", "nn") + ":#{node[:hadoop][:nn][:port]}"

template "#{node[:hadoop][:home]}/etc/hadoop/core-site.xml" do 
  source "core-site.xml.erb"
  owner node[:hdfs][:user]
  group node[:hadoop][:group]
  mode "755"
  variables({
              :firstNN => firstNN
            })
  action :create_if_missing
end

template "#{node[:hadoop][:home]}/etc/hadoop/hdfs-site.xml" do
  source "hdfs-site.xml.erb"
  owner node[:hdfs][:user]
  group node[:hadoop][:group]
  mode "755"
  variables({
              :addr1 => my_ip + ":40100",
              :addr2 => my_ip + ":40101",
              :addr3 => my_ip + ":40102",
              :addr4 => my_ip + ":40103",
              :addr5 => my_ip + ":40104",
            })
  action :create_if_missing
end

template "#{node[:hadoop][:home]}/etc/hadoop/hadoop-env.sh" do
  source "hadoop-env.sh.erb"
  owner node[:hdfs][:user]
  group node[:hadoop][:group]
  mode "755"
end


template "#{node[:hadoop][:home]}/etc/hadoop/jmxremote.password" do 
  source "jmxremote.password.erb"
  owner node[:hdfs][:user]
  group node[:hadoop][:group]
  mode "600"
end

template "#{node[:hadoop][:home]}/etc/hadoop/yarn-jmxremote.password" do 
  source "jmxremote.password.erb"
  owner node[:hadoop][:yarn][:user]
  group node[:hadoop][:group]
  mode "600"
end


template "#{node[:hadoop][:home]}/sbin/kill-process.sh" do 
  source "kill-process.sh.erb"
  owner node[:hdfs][:user]
  group node[:hadoop][:group]
  mode "754"
end

template "#{node[:hadoop][:home]}/sbin/set-env.sh" do 
  source "set-env.sh.erb"
  owner node[:hdfs][:user]
  group node[:hadoop][:group]
  mode "774"
end


l = node[:hadoop][:nn][:private_ips].length
last=node[:hadoop][:nn][:private_ips][l-1]
first=node[:hadoop][:nn][:private_ips][0]

if node[:hadoop][:install_protobuf]
  proto_url = node[:protobuf][:url]
  Chef::Log.info "Downloading hadoop binaries from #{proto_url}"
  proto = File.basename(proto_url)
  proto_filename = "#{Chef::Config[:file_cache_path]}/#{proto}"

  remote_file proto_filename do
    source proto_url
    owner node[:hdfs][:user]
    group node[:hadoop][:group]
    mode "0755"
    # TODO - checksum
    action :create_if_missing
  end

  bash "install_protobuf_2_5" do
    user node[:hdfs][:user]
    code <<-EOF
    apt-get -y remove protobuf-compiler
    tar -xzf #{proto_filename} -C #{Chef::Config[:file_cache_path]}
    cd #{Chef::Config[:file_cache_path]}/protobuf-2.5.0
    ./configure --prefix=/usr
    make
    make install
    protoc --version
    EOF
    not_if { "protoc --version | grep 2\.5" }
  end
end


hadoop_user_envs node[:hdfs][:user] do
  action :update
end

hadoop_user_envs node[:hadoop][:yarn][:user] do
  action :update
end

hadoop_user_envs node[:hadoop][:mr][:user] do
  action :update
end

directory "/conf" do
  owner "root"
  group node[:hadoop][:group]
  mode "0755"
  recursive true
  action :create
end


template "/conf/container-executor.cfg" do
  source "container-executor.cfg.erb"
  owner node[:hdfs][:user]
  group node[:hadoop][:group]
  mode "755"
end
