
case node.platform
when "ubuntu"
 if node.platform_version.to_f <= 14.04
   node.override.apache_hadoop.systemd = "false"
 end
end

for script in node.apache_hadoop.dn.scripts
  template "#{node.apache_hadoop.home}/sbin/#{script}" do
    source "#{script}.erb"
    owner node.apache_hadoop.hdfs.user
    owner node.apache_hadoop.hdfs.user
    group node.apache_hadoop.group
    mode 0775
  end
end 

service_name="datanode"

service "#{service_name}" do
case node.apache_hadoop.systemd
  when "true"
  provider Chef::Provider::Service::Systemd
  else
  provider Chef::Provider::Service::Init::Debian
end
  supports :restart => true, :stop => true, :start => true, :status => true
  action :nothing
end

template "/etc/init.d/#{service_name}" do
  not_if { node.apache_hadoop.systemd == "true" }
  source "#{service_name}.erb"
  owner "root"
  group "root"
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
    only_if { node.apache_hadoop.systemd == "true" }
    source "#{service_name}.service.erb"
    owner node.apache_hadoop.hdfs.user
    group node.apache_hadoop.group
    mode 0754
    notifies :enable, "service[#{service_name}]"
    notifies :restart, "service[#{service_name}]", :immediately
end


if node.kagent.enabled == "true" 
  kagent_config "#{service_name}" do
    service "HDFS"
    start_script "#{node.apache_hadoop.home}/sbin/root-start-dn.sh"
    stop_script "#{node.apache_hadoop.home}/sbin/stop-dn.sh"
    log_file "#{node.apache_hadoop.logs_dir}/hadoop-#{node.apache_hadoop.hdfs.user}-#{service_name}-#{node.hostname}.log"
    pid_file "#{node.apache_hadoop.logs_dir}/hadoop-#{node.apache_hadoop.hdfs.user}-#{service_name}.pid"
    config_file "#{node.apache_hadoop.conf_dir}/hdfs-site.xml"
    web_port node.apache_hadoop.dn.http_port
    command "hdfs"
    command_user node.apache_hadoop.hdfs.user
    command_script "#{node.apache_hadoop.home}/bin/hdfs"
  end
end
