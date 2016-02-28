include_recipe "apache_hadoop::yarn"

case node.platform
when "ubuntu"
 if node.platform_version.to_f <= 14.04
   node.override.hadoop.systemd = "false"
 end
end


yarn_service="nm"
service_name="nodemanager"

for script in node.apache_hadoop.yarn.scripts
  template "#{node.apache_hadoop.home}/sbin/#{script}-#{yarn_service}.sh" do
    source "#{script}-#{yarn_service}.sh.erb"
    owner node.apache_hadoop.yarn.user
    group node.apache_hadoop.group
    mode 0775
  end
end 


service service_name do
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
  owner node.apache_hadoop.yarn.user
  group node.apache_hadoop.group
  mode 0754
  notifies :enable, resources(:service => service_name)
  notifies :restart, resources(:service => service_name), :immediately
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
    owner "root"
    group "root"
    mode 0754
    notifies :enable, resources(:service => service_name)
    notifies :restart, resources(:service => service_name), :immediately
end


if node.kagent.enabled == "true" 
  kagent_config service_name do
    service "YARN"
    start_script "#{node.apache_hadoop.home}/sbin/root-start-#{yarn_service}.sh"
    stop_script "#{node.apache_hadoop.home}/sbin/stop-#{yarn_service}.sh"
    log_file "#{node.apache_hadoop.logs_dir}/yarn-#{node.apache_hadoop.yarn.user}-#{service_name}-#{node.hostname}.log"
    pid_file "#{node.apache_hadoop.logs_dir}/yarn-#{node.apache_hadoop.yarn.user}-#{service_name}.pid"
    web_port node.apache_hadoop["#{yarn_service}"][:http_port]
  end
end

