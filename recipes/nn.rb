
case node.platform
when "ubuntu"
 if node.platform_version.to_f <= 14.04
   node.override.hadoop.systemd = "false"
 end
end

private_ip = my_private_ip()
public_ip = my_public_ip()

for script in node.hadoop.nn.scripts
  template "#{node.hadoop.home}/sbin/#{script}" do
    source "#{script}.erb"
    owner node.hdfs.user
    group node.hadoop.group
    mode 0775
  end
end 

activeNN = true
ha_enabled = false
if node.hadoop.ha_enabled.eql? "true" || node.hadoop.ha_enabled == true
  ha_enabled = true
end

# it is ok if all namenodes format the fs. Unless you add a new one later..
# if the nn has already been formatted, re-formatting it returns error
# TODO: test if the NameNode is running
if ::File.exist?("#{node.hadoop.home}/.nn_formatted") === false || "#{node.hadoop.reformat}" === "true"
  if activeNN == true
    sleep 10
    hadoop_start "format-nn" do
      action :format_nn
      ha_enabled ha_enabled
    end
  else
    # wait for the active nn to come up
    # TODO - copy fsimage over from the active nn
    sleep 100
  end
else 
  Chef::Log.info "Not formatting the NameNode. Remove this directory before formatting: (sudo rm -rf #{node.hadoop.nn.name_dir}/current) and set node.hadoop.reformat to true"
end

if ha_enabled == true

  template "#{node.hadoop.home}/sbin/start-zkfc.sh" do
    source "start-zkfc.sh.erb"
    owner node.hdfs.user
    group node.hadoop.group
    mode 0754
  end

  template "#{node.hadoop.home}/sbin/start-standby-nn.sh" do
    source "start-standby-nn.sh.erb"
    owner node.hdfs.user
    group node.hadoop.group
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

service_name="namenode"

service "#{service_name}" do
case node.hadoop.systemd
  when "true"
  provider Chef::Provider::Service::Systemd
  else
  provider Chef::Provider::Service::Init::Debian
end
  supports :restart => true, :stop => true, :start => true, :status => true
  action :nothing 
end

template "/etc/init.d/#{service_name}" do
  not_if { node.hadoop.systemd == "true" }
  source "#{service_name}.erb"
  owner node.hdfs.user
  group node.hadoop.group
  mode 0754
  notifies :enable, resources(:service => "#{service_name}")
  notifies :restart, resources(:service => "#{service_name}"), :immediately
end

case node.platform_family
  when "debian"
systemd_script = "/lib/systemd/system/#{service_name}.service"
  when "rhel"
systemd_script = "/usr/lib/systemd/system/#{service_name}.service" 
end

template systemd_script do
    only_if { node.hadoop.systemd == "true" }
    source "#{service_name}.service.erb"
    owner "root"
    group "root"
    mode 0754
    notifies :enable, "service[#{service_name}]"
    notifies :restart, "service[#{service_name}]", :immediately
end




if node.kagent.enabled == "true" 
  kagent_config "#{service_name}" do
    service "HDFS"
    start_script "#{node.hadoop.home}/sbin/root-start-nn.sh"
    stop_script "#{node.hadoop.home}/sbin/stop-nn.sh"
    init_script "#{node.hadoop.home}/sbin/format-nn.sh"
    config_file "#{node.hadoop.conf_dir}/core-site.xml"
    log_file "#{node.hadoop.logs_dir}/hadoop-#{node.hdfs.user}-#{service_name}-#{node.hostname}.log"
    pid_file "#{node.hadoop.logs_dir}/hadoop-#{node.hdfs.user}-#{service_name}.pid"
    web_port node.hadoop.nn.http_port
  end
end

