
# hdfs-daemon.sh journalnode

my_ip = my_private_ip()

template "#{node[:hadoop][:home]}/sbin/start-jn.sh" do
  source "start-jn.sh.erb"
  owner node[:hdfs][:user]
  group node[:hadoop][:group]
  mode 0754
end



bash "start_journal_node" do
 user node[:hdfs][:user]
 code <<-EOF
    cd #{node[:hadoop][:sbin_dir]}
    . ./set-env.sh
    ./hadoop-daemons.sh --config "#{node[:hadoop][:conf_dir]}" --hostnames "#{my_ip}" --script "#{node[:hadoop][:bin_dir]}/hdfs" start journalnode
  EOF
  not_if { "ps -aux | journalnode" }
end

