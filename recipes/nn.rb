
my_ip = my_private_ip()
public_ip = my_public_ip()

for script in node[:hadoop][:nn][:scripts]
  template "#{node[:hadoop][:home]}/sbin/#{script}" do
    source "#{script}.erb"
    owner node[:hdfs][:user]
    group node[:hadoop][:group]
    mode 0775
  end
end 

activeNN = true
ha_enabled = false
if "#{node[:hadoop][:ha_enabled]}".eql? "true" 
  ha_enabled = true
end


if ha_enabled == true
  if node[:hadoop][:nn][:private_ips].size > 1
    if node[:hadoop][:nn][:private_ips][1].eql? my_ip
       activeNN = false
    end
  end
end

# it is ok if all namenodes format the fs. Unless you add a new one later..
# if the nn has already been formatted, re-formatting it returns error
# TODO: test if the NameNode is running
if ::File.exist?("#{node[:hadoop][:home]}/.nn_formatted") === false || "#{node[:hadoop][:reformat]}" === "true"
  if activeNN == true
    hadoop_start "format-nn" do
      action :format_nn
      ha_enabled ha_enabled
    end
  end
else 
  Chef::Log.info "Not formatting the NameNode. Remove this directory before formatting: (sudo rm -rf #{node[:hadoop][:nn][:name_dir]}/current) and set node[:hadoop][:reformat] to true"
end

if ha_enabled == true

template "#{node[:hadoop][:home]}/sbin/start-zkfc.sh" do
  source "start-zkfc.sh.erb"
  owner node[:hdfs][:user]
  group node[:hadoop][:group]
  mode 0754
end

template "#{node[:hadoop][:home]}/sbin/start-standby-nn.sh" do
  source "start-standby-nn.sh.erb"
  owner node[:hdfs][:user]
  group node[:hadoop][:group]
  mode 0754
end


  hadoop_start "zookeeper-format" do
    action :zkfc
    ha_enabled ha_enabled
  end

  if activeNN == false
    hadoop_start "standby-nn" do
      action :standby
      ha_enabled ha_enabled
    end
  end
end

service "namenode" do
  supports :restart => true, :stop => true, :start => true, :status => true
  action :nothing 
end

template "/etc/init.d/namenode" do
  source "namenode.erb"
  owner node[:hdfs][:user]
  group node[:hadoop][:group]
  mode 0754
  notifies :enable, resources(:service => "namenode")
  notifies :restart, resources(:service => "namenode")
end

if node[:kagent][:enabled] == "true" 
  kagent_config "namenode" do
    service "HDFS"
    start_script "#{node[:hadoop][:home]}/sbin/root-start-nn.sh"
    stop_script "#{node[:hadoop][:home]}/sbin/stop-nn.sh"
    init_script "#{node[:hadoop][:home]}/sbin/format-nn.sh"
    config_file "#{node[:hadoop][:conf_dir]}/core-site.xml"
    log_file "#{node[:hadoop][:logs_dir]}/hadoop-#{node[:hdfs][:user]}-namenode-#{node['hostname']}.log"
    pid_file "#{node[:hadoop][:logs_dir]}/hadoop-#{node[:hdfs][:user]}-namenode.pid"
    web_port node[:hadoop][:nn][:http_port]
  end
end

hadoop_start "namenode" do
end

