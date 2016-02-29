
# hdfs-daemon.sh journalnode

my_ip = my_private_ip()

template "#{node.apache_hadoop.home}/sbin/start-jn.sh" do
  source "start-jn.sh.erb"
  owner node.apache_hadoop.hdfs.user
  group node.apache_hadoop.group
  mode 0754
end


apache_hadoop_start "journal-node" do
  ha_enabled true
  action :jn
end


