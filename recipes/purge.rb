daemons = %w{namenode datanode resourcemanager nodemanager historyserver proxyserver}
daemons.each { |d| 

bash 'uninstall_service_#{d}' do
user "root"
ignore_failure :true
code <<-EOF
 service stop #{d}
 killall -9 #{d}
EOF
end

file "/etc/init.d/#{d}" do
  action :delete
  ignore_failure :true
end

}

directory node[:hadoop][:home] do
  recursive true
  action :delete
  ignore_failure :true
end

directory node[:hadoop][:data_dir] do
  recursive true
  action :delete
  ignore_failure :true
end

directory Chef::Config[:file_cache_path] do
  recursive true
  action :delete
  ignore_failure :true
end
