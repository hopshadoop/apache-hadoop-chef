include_attribute "kagent"

default.apache_hadoop.version                  = "2.4.0"
default.apache_hadoop.hdfs.user                = "hdfs"
default.apache_hadoop.group                    = "hadoop"
default.apache_hadoop.dir                      = "/srv"
default.apache_hadoop.base_dir                 = "#{node.apache_hadoop.dir}/hadoop"
default.apache_hadoop.home                     = "#{node.apache_hadoop.dir}/hadoop-#{node.apache_hadoop.version}"
default.apache_hadoop.logs_dir                 = "#{node.apache_hadoop.home}/logs"
default.apache_hadoop.tmp_dir                  = "#{node.apache_hadoop.home}/tmp"
default.apache_hadoop.conf_dir                 = "#{node.apache_hadoop.home}/etc/hadoop"
default.apache_hadoop.sbin_dir                 = "#{node.apache_hadoop.home}/sbin"
default.apache_hadoop.bin_dir                  = "#{node.apache_hadoop.home}/bin"
default.apache_hadoop.data_dir                 = "/var/data/hadoop"
default.apache_hadoop.dn.data_dir              = "#{node.apache_hadoop.data_dir}/hdfs/dn"
default.apache_hadoop.nn.name_dir              = "#{node.apache_hadoop.data_dir}/hdfs/nn"

default.apache_hadoop.hdfs.user_home           = "/user"
default.apache_hadoop.hdfs.active_nn           = true


default.apache_hadoop.download_url.primary     = "#{download_url}/hadoop-#{node.apache_hadoop.version}.tar.gz"
default.apache_hadoop.download_url.secondary   = "https://archive.apache.org/dist/hadoop/core/hadoop-#{node.apache_hadoop.version}/hadoop-#{node.apache_hadoop.version}.tar.gz"

default.apache_hadoop.install_protobuf         = "false"
default.apache_hadoop.protobuf_url             = "https://protobuf.googlecode.com/files/protobuf-2.5.0.tar.gz"
default.apache_hadoop.hadoop_src_url           = "https://archive.apache.org/dist/hadoop/core/hadoop-#{node.apache_hadoop.version}/hadoop-#{node.apache_hadoop.version}-src.tar.gz"
default.apache_hadoop.nn.http_port             = 50070
default.apache_hadoop.dn.http_port             = 50075
default.apache_hadoop.nn.port                  = 8020

default.apache_hadoop.leader_check_interval_ms = 1000
default.apache_hadoop.missed_hb                = 1
default.apache_hadoop.num_replicas             = 3
default.apache_hadoop.db                       = "hadoop"
default.apache_hadoop.nn.scripts               = %w{ format-nn.sh start-nn.sh stop-nn.sh restart-nn.sh root-start-nn.sh hdfs.sh yarn.sh hadoop.sh } 
default.apache_hadoop.dn.scripts               = %w{ start-dn.sh stop-dn.sh restart-dn.sh root-start-dn.sh hdfs.sh yarn.sh hadoop.sh } 
default.apache_hadoop.max_retries              = 0
default.apache_hadoop.reformat                 = "false"
default.apache_hadoop.io_buffer_sz             = 131072
default.apache_hadoop.container_cleanup_delay_sec  = 0

default.apache_hadoop.nn.heap_size             = 500

default.apache_hadoop.yarn.scripts             = %w{ start stop restart root-start }
default.apache_hadoop.yarn.user                = "yarn"
default.apache_hadoop.yarn.ps_port             = 20888

default.apache_hadoop.yarn.vpmem_ratio         = 4.1
default.apache_hadoop.yarn.vmem_check          = false
default.apache_hadoop.yarn.pmem_check          = true
default.apache_hadoop.yarn.vcores              = 4
default.apache_hadoop.yarn.min_vcores          = 1
default.apache_hadoop.yarn.max_vcores          = 4
default.apache_hadoop.yarn.log_aggregation     = "true"
#default.apache_hadoop.yarn.nodemanager.remote-app-log-dir =  "/tmp/" + "/logs"
default.apache_hadoop.yarn.nodemanager.remote_app_log_dir = node.apache_hadoop.hdfs.user_home + "/" + node.apache_hadoop.yarn.user + "/logs"
default.apache_hadoop.yarn.log_retain_secs     = 86400
default.apache_hadoop.yarn.log_retain_check    = 100

default.apache_hadoop.yarn.container_cleanup_delay_sec  = 0

default.apache_hadoop.yarn.nodemanager_hb_ms   = "1000"
 
default.apache_hadoop.am.max_retries           = 2

default.apache_hadoop.yarn.aux_services        = "mapreduce_shuffle"

default.apache_hadoop.mr.user                  = "mapred"
default.apache_hadoop.mr.shuffle_class         = "org.apache.hadoop.mapred.ShuffleHandler"

default.apache_hadoop.yarn.app_classpath       = "#{node.apache_hadoop.home}, 
                                                  #{node.apache_hadoop.home}/lib/*, 
                                                  #{node.apache_hadoop.home}/etc/hadoop/,  
                                                  #{node.apache_hadoop.home}/share/hadoop/common/*, 
                                                  #{node.apache_hadoop.home}/share/hadoop/common/lib/*, 
                                                  #{node.apache_hadoop.home}/share/hadoop/hdfs/*, 
                                                  #{node.apache_hadoop.home}/share/hadoop/hdfs/lib/*, 
                                                  #{node.apache_hadoop.home}/share/hadoop/yarn/*, 
                                                  #{node.apache_hadoop.home}/share/hadoop/yarn/lib/*, 
                                                  #{node.apache_hadoop.home}/share/hadoop/tools/lib/*, 
                                                  #{node.apache_hadoop.home}/share/hadoop/mapreduce/*, 
                                                  #{node.apache_hadoop.home}/share/hadoop/mapreduce/lib/*"
#                                                  #{node.apache_hadoop.home}/share/hadoop/yarn/test/*, 
#                                                  #{node.apache_hadoop.home}/share/hadoop/mapreduce/test/*"

default.apache_hadoop.rm.addr                  = []
default.apache_hadoop.rm.http_port             = 8088
default.apache_hadoop.nm.http_port             = 8042
default.apache_hadoop.jhs.http_port            = 19888

default.apache_hadoop.rm.scheduler_class       = "org.apache.hadoop.yarn.server.resourcemanager.scheduler.fifo.FifoScheduler"
#default.apache_hadoop.rm.scheduler_class     = "org.apache.hadoop.yarn.server.resourcemanager.scheduler.capacity.CapacityScheduler"
default.apache_hadoop.rm.scheduler_capacity.calculator_class  = "org.apache.hadoop.yarn.util.resource.DominantResourceCalculator"

default.apache_hadoop.mr.tmp_dir               = "/mapreduce"
default.apache_hadoop.mr.staging_dir           = "#{default.apache_hadoop.mr.tmp_dir}/#{default.apache_hadoop.mr.user}/staging"

default.apache_hadoop.jhs.inter_dir            = "/mr-history/done_intermediate"
default.apache_hadoop.jhs.done_dir             = "/mr-history/done"

# YARN CONFIG VARIABLES
# http://hadoop.apache.org/docs/current/hadoop-yarn/hadoop-yarn-common/yarn-default.xml
# If you need mapreduce, mapreduce.shuffle should be included here.
# You can have a comma-separated list of services
# http://hadoop.apache.org/docs/r2.1.0-beta/hadoop-mapreduce-client/hadoop-mapreduce-client-core/PluggableShuffleAndPluggableSort.html

default.apache_hadoop.nn.jmxport               = "8077"
default.apache_hadoop.rm.jmxport               = "8082"
default.apache_hadoop.nm.jmxport               = "8083"

default.apache_hadoop.jmx.username             = "monitorRole"
default.apache_hadoop.jmx.password             = "hadoop"


default.apache_hadoop.nn.public_ips            = ['10.0.2.15']
default.apache_hadoop.nn.private_ips           = ['10.0.2.15']
default.apache_hadoop.dn.public_ips            = ['10.0.2.15']
default.apache_hadoop.dn.private_ips           = ['10.0.2.15']
default.apache_hadoop.rm.public_ips            = ['10.0.2.15']
default.apache_hadoop.rm.private_ips           = ['10.0.2.15']
default.apache_hadoop.nm.public_ips            = ['10.0.2.15']
default.apache_hadoop.nm.private_ips           = ['10.0.2.15']
default.apache_hadoop.jhs.public_ips           = ['10.0.2.15']
default.apache_hadoop.jhs.private_ips          = ['10.0.2.15']
default.apache_hadoop.ps.public_ips            = ['10.0.2.15']
default.apache_hadoop.ps.private_ips           = ['10.0.2.15']

# comma-separated list of namenode addrs
default.apache_hadoop.nn.addrs                 = []

# build the native libraries. Is much slower, but removes warning when using services.
default.apache_hadoop.native_libraries         = "false"
default.apache_hadoop.cgroups                  = "false"

default.maven.version                          = "3.2.5"
default.maven.checksum                         = ""


# If yarn.nm.memory_mbs is not set, then memory_percent is used instead
default.apache_hadoop.yarn.nm.memory_mbs       = 2500
default.apache_hadoop.yarn.memory_percent      = "75"

default.apache_hadoop.limits.nofile            = '32768'
default.apache_hadoop.limits.nproc             = '65536'
default.apache_hadoop.limits.memory_limit      = '100000'
default.apache_hadoop.os_defaults              = "true"

default.apache_hadoop.user_envs                = "true"

default.apache_hadoop.logging_level            = "WARN"
default.apache_hadoop.nn.direct_memory_size    = 100
default.apache_hadoop.ha_enabled               = "false"

default.apache_hadoop.systemd                  = "true"


