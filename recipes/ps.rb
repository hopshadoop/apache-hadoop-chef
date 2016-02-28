include_recipe "hadoop::yarn"

yarn_service="ps"
service_name="proxyserver"

for script in node.hadoop.yarn.scripts
  template "#{node.hadoop.home}/sbin/#{script}-#{yarn_service}.sh" do
    source "#{script}-#{yarn_service}.sh.erb"
    owner node.hadoop.yarn.user
    group node.hadoop.group
    mode 0775
  end
end 

# hop_yarn_services node.hadoop.services do
#   action "install_#{yarn_service}"
# end

service service_name do
  case node.hadoop.use_systemd
    when "true"
    provider Chef::Provider::Service::Systemd
  end
  supports :restart => true, :stop => true, :start => true, :status => true
  action :nothing
end

template "/etc/init.d/#{service_name}" do
  source "#{service_name}.erb"
  owner node.hadoop.yarn.user
  group node.hadoop.group
  mode 0754
  notifies :enable, resources(:service => service_name)
  notifies :restart, resources(:service => service_name)
end

case node.platform_family
  when "debian"
systemd_script = "/lib/systemd/system/#{service_name}.service"
  when "rhel"
systemd_script = "/usr/lib/systemd/system/#{service_name}.service" 
end

template systemd_script do
    only_if { node.hadoop.use_systemd == "true" }
    source "#{service_name}.service.erb"
    owner "root"
    group "root"
    mode 0754
    notifies :enable, "service[#{service_name}]"
    notifies :restart, "service[#{service_name}]"
end



if node.kagent.enabled == "true" 
  kagent_config service_name do
    service "YARN"
    start_script "#{node.hadoop.home}/sbin/root-start-#{yarn_service}.sh"
    stop_script "#{node.hadoop.home}/sbin/stop-#{yarn_service}.sh"
    log_file "#{node.hadoop.logs_dir}/yarn-#{node.hdfs.user}-#{service_name}-#{node.hostname}.log"
    pid_file "#{node.hadoop.logs_dir}/yarn-#{node.hdfs.user}-#{service_name}.pid"
    web_port node.hadoop["#{yarn_service}"][:http_port]
  end
end

