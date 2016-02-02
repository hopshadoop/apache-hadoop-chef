include_recipe "hadoop::yarn"
libpath = File.expand_path '../../../kagent/libraries', __FILE__
require File.join(libpath, 'inifile')

yarn_service="jhs"
service_name="historyserver"

for script in node[:hadoop][:yarn][:scripts]
  template "#{node[:hadoop][:home]}/sbin/#{script}-#{yarn_service}.sh" do
    source "#{script}-#{yarn_service}.sh.erb"
    owner node[:hadoop][:yarn][:user]
    group node[:hadoop][:group]
    mode 0775
  end
end 

service service_name do
  if node[:hadoop][:use_systemd] == "true"
    provider Chef::Provider::Service::Systemd
  end
  supports :restart => true, :stop => true, :start => true, :status => true
  action :nothing
end


tmp_dirs   = ["/mr-history", node[:hadoop][:jhs][:inter_dir], node[:hadoop][:jhs][:done_dir], "/tmp", node[:hdfs][:user_home]]

 for d in tmp_dirs
   Chef::Log.info "Creating hdfs directory: #{d}"
   hadoop_hdfs_directory d do
    action :create_as_superuser
    owner node[:hdfs][:user]
    group node[:hadoop][:group]
    mode "1777"
    not_if ". #{node[:hadoop][:home]}/sbin/set-env.sh && #{node[:hadoop][:home]}/bin/hdfs dfs -test -d #{d}"
   end
 end

node.normal[:mr][:dirs] = [node[:hadoop][:mr][:staging_dir], node[:hadoop][:mr][:tmp_dir], node[:hdfs][:user_home] + "/" + node[:hadoop][:mr][:user]]
 for d in node[:mr][:dirs]
   Chef::Log.info "Creating hdfs directory: #{d}"
   hadoop_hdfs_directory d do
    action :create_as_superuser
    owner node[:hadoop][:mr][:user]
    group node[:hadoop][:group]
    mode "0775"
    not_if ". #{node[:hadoop][:home]}/sbin/set-env.sh && #{node[:hadoop][:home]}/bin/hdfs dfs -test -d #{d}"
   end
 end

template "/etc/init.d/#{service_name}" do
  not_if { node[:hadoop][:use_systemd] == "true" }
  source "#{service_name}.erb"
  owner node[:hdfs][:user]
  group node[:hadoop][:group]
  mode 0754
  notifies :enable, resources(:service => service_name)
  notifies :restart, resources(:service => service_name)
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
    owner "root"
    group "root"
    mode 0754
    notifies :enable, "service[#{service_name}]"
    notifies :restart, "service[#{service_name}]", :immediately
end


if node[:kagent][:enabled] == "true" 
  kagent_config service_name do
    service "MAP_REDUCE"
    start_script "#{node[:hadoop][:home]}/sbin/root-start-#{yarn_service}.sh"
    stop_script "#{node[:hadoop][:home]}/sbin/stop-#{yarn_service}.sh"
    log_file "#{node[:hadoop][:logs_dir]}/yarn-#{node[:hdfs][:user]}-#{service_name}-#{node['hostname']}.log"
    pid_file "/tmp/mapred-#{node[:hdfs][:user]}-#{service_name}.pid"
    config_file "#{node[:hadoop][:conf_dir]}/mapred-site.xml"
    web_port node[:hadoop]["#{yarn_service}"][:http_port]
  end
end

#hadoop_start "#{service_name}" do
#end
