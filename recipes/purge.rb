daemons = %w{namenode datanode resourcemanager nodemanager historyserver proxyserver}
daemons.each { |d| 
  bash 'uninstall_service_#{d}' do
    user "root"
    ignore_failure true
    code <<-EOF
 service #{d} stop
 systemctl stop #{d}
 pkillall -9 #{d}
EOF
  end

  file "/etc/init.d/#{d}" do
    action :delete
    ignore_failure true
  end
  file "/usr/lib/systemd/systemd/#{d}.service" do
    action :delete
    ignore_failure true
  end
  file "/lib/systemd/systemd/#{d}.service" do
    action :delete
    ignore_failure true
  end
}

directory "#{node.apache_hadoop.dir}/hadoop-#{node.apache_hadoop.version}" do
  recursive true
  action :delete
  ignore_failure true
end

link node.apache_hadoop.home do
  action :delete
  ignore_failure true
end

directory node.apache_hadoop.data_dir do
  recursive true
  action :delete
  ignore_failure true
end

directory Chef::Config.file_cache_path do
  recursive true
  action :delete
  ignore_failure true
end

package "Bouncy Castle Remove" do
  case node.platform
  when 'redhat', 'centos'
    package_name 'bouncycastle'
  when 'ubuntu', 'debian'
    package_name 'bouncycastle'
  end
 ignore_failure true
 action :purge
end
