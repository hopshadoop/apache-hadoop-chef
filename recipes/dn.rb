libpath = File.expand_path '../../../kagent/libraries', __FILE__
require File.join(libpath, 'inifile')


for script in node[:hadoop][:dn][:scripts]
  template "#{node[:hadoop][:home]}/sbin/#{script}" do
    source "#{script}.erb"
    owner node[:hdfs][:user]
    group node[:hadoop][:group]
    mode 0775
  end
end 

service_name="datanode"

service "#{service_name}" do
  case node[:hadoop][:use_systemd]
    when "true"
    provider Chef::Provider::Service::Systemd
  end
  supports :restart => true, :stop => true, :start => true, :status => true
  action :nothing
end

template "/etc/init.d/#{service_name}" do
  not_if { node[:hadoop][:use_systemd] == "true" }
  source "#{service_name}.erb"
  owner "root"
  group "root"
  mode 0754
  notifies :enable, resources(:service => "#{service_name}")
  notifies :restart, resources(:service => "#{service_name}")
end

case node[:platform_family]
  when "debian"
systemd_script = "/lib/systemd/system/#{service_name}.service"
  when "rhel"
systemd_script = "/usr/lib/systemd/system/#{service_name}.service" 
end

template systemd_script do
    only_if { node[:hadoop][:use_systemd] == "true" }
    source "#{service_name}.service.erb"
    owner node[:hdfs][:user]
    group node[:hadoop][:group]
    mode 0754
    notifies :enable, "service[#{service_name}]"
    notifies :restart, "service[#{service_name}]", :immediately
end


if node[:kagent][:enabled] == "true" 
  kagent_config "#{service_name}" do
    service "HDFS"
    start_script "#{node[:hadoop][:home]}/sbin/root-start-dn.sh"
    stop_script "#{node[:hadoop][:home]}/sbin/stop-dn.sh"
    log_file "#{node[:hadoop][:logs_dir]}/hadoop-#{node[:hdfs][:user]}-#{service_name}-#{node['hostname']}.log"
    pid_file "#{node[:hadoop][:logs_dir]}/hadoop-#{node[:hdfs][:user]}-#{service_name}.pid"
    config_file "#{node[:hadoop][:conf_dir]}/hdfs-site.xml"
    web_port node[:hadoop][:dn][:http_port]
    command "hdfs"
    command_user node[:hdfs][:user]
    command_script "#{node[:hadoop][:home]}/bin/hdfs"
  end
end

# hadoop_start "#{service_name}" do
# end
