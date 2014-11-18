node.normal[:mr][:dirs] = [node[:mr][:staging_dir], node[:mr][:tmp_dir]]
tmp_dirs   = [node[:jhs][:inter_dir], node[:jhs][:done_dir], "/tmp"]

for d in tmp_dirs
  hadoop_hdfs_directory d do
   action :create
   mode "1777"
  end
end

for d in node[:mr][:dirs]
  Chef::Log.info "One Creating hdfs directory: #{d}"
  hadoop_hdfs_directory d do
   action :create
   mode "0755"
  end
end


bash 'restart-nn' do
  user node[:hdfs][:user]
  code <<-EOH
 		#{node[:hadoop][:home]}/sbin/restart-nn.sh
 	EOH
end
