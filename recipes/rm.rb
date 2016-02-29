include_recipe "apache_hadoop::yarn"

yarn_service="rm"
service_name="resourcemanager"
my_ip = my_private_ip()
my_public_ip = my_public_ip()
container_executor="org.apache.hadoop.yarn.server.nodemanager.DefaultContainerExecutor"
if node.apache_hadoop.cgroups.eql? "true" 
  container_executor="org.apache.hadoop.yarn.server.nodemanager.LinuxContainerExecutor"
end


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
              :rm_private_ip => my_ip,
              :rm_public_ip => my_public_ip,
              :available_mem_mb => node.apache_hadoop.yarn.nm.memory_mbs,
              :my_public_ip => my_public_ip,
              :my_private_ip => my_ip,
              :container_executor => container_executor
            })
  action :create_if_missing
end


for script in node.apache_hadoop.yarn.scripts
  template "#{node.apache_hadoop.home}/sbin/#{script}-#{yarn_service}.sh" do
    source "#{script}-#{yarn_service}.sh.erb"
    owner node.apache_hadoop.yarn.user
    group node.apache_hadoop.group
    mode 0775
  end
end 

template "#{node.apache_hadoop.home}/sbin/yarn.sh" do
  source "yarn.sh.erb"
  owner node.apache_hadoop.yarn.user
  group node.apache_hadoop.group
  mode 0775
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
    notifies :enable, "service[#{service_name}]"
    notifies :restart, "service[#{service_name}]", :immediately
end



if node.kagent.enabled == "true" 
  kagent_config service_name do
    service "YARN"
    start_script "#{node.apache_hadoop.home}/sbin/root-start-#{yarn_service}.sh"
    stop_script "#{node.apache_hadoop.home}/sbin/stop-#{yarn_service}.sh"
    log_file "#{node.apache_hadoop.logs_dir}/yarn-#{node.apache_hadoop.yarn.user}-#{service_name}-#{node.hostname}.log"
    pid_file "#{node.apache_hadoop.logs_dir}/yarn-#{node.apache_hadoop.yarn.user}-#{service_name}.pid"
    config_file "#{node.apache_hadoop.conf_dir}/yarn-site.xml"
    web_port node.apache_hadoop["#{yarn_service}"][:http_port]
    command "yarn"
    command_user node.apache_hadoop.yarn.user
    command_script "#{node.apache_hadoop.home}/bin/yarn"
  end
end

