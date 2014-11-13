action :create do
  Chef::Log.info "Creating hdfs directory: #{@new_resource}"
  Chef::Log.info "Creating hdfs directory: #{@new_resource.name}"

  bash "mk-dir-#{new_resource.name}" do
    user node[:hdfs][:user]
    code <<-EOF
     . #{node[:hadoop][:home]}/sbin/set-env.sh
     #{node[:hadoop][:home]}/bin/hdfs dfs -mkdir -p #{new_resource.name}
     #{node[:hadoop][:home]}/bin/hadoop fs -chmod #{new_resource.mode} #{new_resource.name} 
     #{node[:hadoop][:home]}/bin/hadoop fs -chown -R #{new_resource.owner} #{new_resource.name} 
    EOF
    not_if ". #{node[:hadoop][:home]}/sbin/set-env.sh && #{node[:hadoop][:home]}/bin/hdfs dfs -test -d #{new_resource.name}"
  end
 
end


action :mapred_dirs do
  node.normal[:mr][:dirs] = [node[:hadoop][:mr][:staging_dir], node[:hadoop][:mr][:tmp_dir]]
  tmp_dirs   = [node[:hadoop][:jhs][:inter_dir], node[:hadoop][:jhs][:done_dir], "/tmp"]

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
end
