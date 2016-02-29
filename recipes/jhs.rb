include_recipe "apache_hadoop::yarn"


yarn_service="jhs"
service_name="historyserver"

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


tmp_dirs   = ["/mr-history", node.apache_hadoop.jhs.inter_dir, node.apache_hadoop.jhs.done_dir, "/tmp", node.apache_hadoop.hdfs.user_home]

 for d in tmp_dirs
   Chef::Log.info "Creating hdfs directory: #{d}"
   apache_hadoop_hdfs_directory d do
    action :create_as_superuser
    owner node.apache_hadoop.hdfs.user
    group node.apache_hadoop.group
    mode "1777"
    not_if ". #{node.apache_hadoop.home}/sbin/set-env.sh && #{node.apache_hadoop.home}/bin/hdfs dfs -test -d #{d}"
   end
 end

node.normal.mr.dirs = [node.apache_hadoop.mr.staging_dir, node.apache_hadoop.mr.tmp_dir, node.apache_hadoop.hdfs.user_home + "/" + node.apache_hadoop.mr.user]
 for d in node.mr.dirs
   Chef::Log.info "Creating hdfs directory: #{d}"
   apache_hadoop_hdfs_directory d do
    action :create_as_superuser
    owner node.apache_hadoop.mr.user
    group node.apache_hadoop.group
    mode "0775"
    not_if ". #{node.apache_hadoop.home}/sbin/set-env.sh && #{node.apache_hadoop.home}/bin/hdfs dfs -test -d #{d}"
   end
 end

template "/etc/init.d/#{service_name}" do
  not_if { node.apache_hadoop.systemd == "true" }
  source "#{service_name}.erb"
  owner node.apache_hadoop.hdfs.user
  owner node.apache_hadoop.hdfs.user
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
    service "MAP_REDUCE"
    start_script "#{node.apache_hadoop.home}/sbin/root-start-#{yarn_service}.sh"
    stop_script "#{node.apache_hadoop.home}/sbin/stop-#{yarn_service}.sh"
    log_file "#{node.apache_hadoop.logs_dir}/yarn-#{node.apache_hadoop.hdfs.user}-#{service_name}-#{node.hostname}.log"
    pid_file "/tmp/mapred-#{node.apache_hadoop.hdfs.user}-#{service_name}.pid"
    config_file "#{node.apache_hadoop.conf_dir}/mapred-site.xml"
    web_port node.apache_hadoop["#{yarn_service}"][:http_port]
  end
end

