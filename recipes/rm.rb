include_recipe "hadoop::yarn"
libpath = File.expand_path '../../../kagent/libraries', __FILE__
require File.join(libpath, 'inifile')


case node.platform
when "ubuntu"
 if node.platform_version.to_f <= 14.04
   node.override.hadoop.systemd = "false"
 end
end


yarn_service="rm"
service_name="resourcemanager"

for script in node[:hadoop][:yarn][:scripts]
  template "#{node[:hadoop][:home]}/sbin/#{script}-#{yarn_service}.sh" do
    source "#{script}-#{yarn_service}.sh.erb"
    owner node[:hadoop][:yarn][:user]
    group node[:hadoop][:hadoop]
    mode 0775
  end
end 

template "#{node[:hadoop][:home]}/sbin/yarn.sh" do
  source "yarn.sh.erb"
  owner node[:hadoop][:yarn][:user]
  group node[:hadoop][:hadoop]
  mode 0775
end


service service_name do
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
  not_if { node[:hadoop][:systemd] == "true" }
  source "#{service_name}.erb"
  owner node[:hadoop][:yarn][:user]
  group node[:hadoop][:hadoop]
  mode 0754
  notifies :enable, resources(:service => service_name)
  notifies :restart, resources(:service => service_name), :immediately
end


case node[:platform_family]
  when "debian"
systemd_script = "/lib/systemd/system/#{service_name}.service"
  when "rhel"
systemd_script = "/usr/lib/systemd/system/#{service_name}.service" 
end

template systemd_script do
    only_if { node[:hadoop][:systemd] == "true" }
    source "#{service_name}.service.erb"
    owner "root"
    group "root"
    mode 0754
    notifies :enable, "service[#{service_name}]"
    notifies :restart, "service[#{service_name}]", :immediately
end



if node[:kagent][:enabled] == "true" 
  kagent_config service_name do
    service "YARN"
    start_script "#{node[:hadoop][:home]}/sbin/root-start-#{yarn_service}.sh"
    stop_script "#{node[:hadoop][:home]}/sbin/stop-#{yarn_service}.sh"
    log_file "#{node[:hadoop][:logs_dir]}/yarn-#{node[:hadoop][:yarn][:user]}-#{service_name}-#{node['hostname']}.log"
    pid_file "#{node[:hadoop][:logs_dir]}/yarn-#{node[:hadoop][:yarn][:user]}-#{service_name}.pid"
    config_file "#{node[:hadoop][:conf_dir]}/yarn-site.xml"
    web_port node[:hadoop]["#{yarn_service}"][:http_port]
    command "yarn"
    command_user node[:hadoop][:yarn][:user]
    command_script "#{node[:hadoop][:home]}/bin/yarn"
  end
end

#hadoop_start "#{service_name}" do
#end
