
# hdfs-daemon.sh journalnode

my_ip = my_private_ip()

template "#{node[:hadoop][:home]}/sbin/start-jn.sh" do
  source "start-jn.sh.erb"
  owner node[:hdfs][:user]
  group node[:hadoop][:group]
  mode 0754
end


hadoop_start "journal-node" do
  ha_enabled true
  action :jn
end


