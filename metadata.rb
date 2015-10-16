name             'hadoop'
maintainer       "Jim Dowling"
maintainer_email "jdowling@kth.se"
license          "GPL 2.0"
description      'Installs/Configures the Apache Hadoop distribution'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "1.0"

#link:<a target='_blank' href='http://%host%:50070/'>Launch the WebUI for the NameNode</a>
recipe            "hadoop::nn", "Installs a Hadoop NameNode"
recipe            "hadoop::dn", "Installs a Hadoop DataNode"
#link:<a target='_blank' href='http://%host%:50088/'>Launch the WebUI for the ResourceManager</a>
recipe            "hadoop::rm", "Installs a YARN ResourceManager"
recipe            "hadoop::nm", "Installs a YARN NodeManager"
#link:<a target='_blank' href='http://%host%:50030/'>Launch the WebUI for the JobTracker</a>
#link:<a target='_blank' href='http://%host%:51111/'>Launch the WebUI for the HistoryServer</a>
recipe            "hadoop::jhs", "Installs a MapReduce History Server for YARN"
recipe            "hadoop::ps", "Installs a WebProxy Server for YARN"


depends 'kagent'
depends 'java'
#depends 'cmake'
depends 'apt'
depends 'yum'
#depends 'build-essential'
depends 'ark'
depends 'ulimit'
depends 'sysctl'

%w{ ubuntu debian rhel centos }.each do |os|
  supports os
end

attribute "hadoop/yarn/nm/memory_mbs",
:display_name => "Hadoop NodeManager Memory in MB",
:type => 'string'

attribute "hadoop/yarn/vcores",
:display_name => "Hadoop NodeManager Number of Virtual Cores",
:type => 'string'

attribute "hadoop/yarn/max_vcores",
:display_name => "Hadoop NodeManager Maximum Number of Virtual Cores",
:type => 'string'

attribute "hadoop/version",
:display_name => "Hadoop version",
:description => "Version of hadoop",
:type => 'string'

attribute "hadoop/yarn/user",
:display_name => "Username to run yarn as",
:description => "Username to run yarn as",
:type => 'string'

attribute "hadoop/mr/user",
:display_name => "Username to run mapReduce as",
:description => "Username to run mapReduce as",
:type => 'string'

attribute "hdfs/user",
:display_name => "Username to run hdfs as",
:description => "Username to run hdfs as",
:type => 'string'

attribute "hadoop/format",
:display_name => "Format HDFS",
:description => "Format HDFS, Run 'hdfs namenode -format",
:type => 'string'

attribute "hadoop/tmp_dir",
:display_name => "Hadoop Temp Dir",
:description => "The directory in which Hadoop stores temporary data, including container data",
:type => 'string'

attribute "hadoop/data_dir",
:display_name => "HDFS Data Dir",
:description => "The directory in which Hadoop's DataNodes store their data",
:type => 'string'

attribute "hadoop/yarn/nodemanager_hb_ms",
:description => "Heartbeat Interval for NodeManager->ResourceManager in ms",
:type => 'string'

attribute "hadoop/num_replicas",
:description => "Number of replicates for each file stored in HDFS",
:type => 'string'

attribute "hadoop/container_cleanup_delay_sec",
:display_name => "Cleanup Delay (s)",
:description => "The number of seconds container data is retained after termination",
:type => 'string'

attribute "hadoop/rm/scheduler_class",
:description => "Java Classname for the Yarn scheduler (fifo, capacity, fair)",
:type => 'string'

attribute "hadoop/user_envs",
:description => "Update the PATH environment variable for the hdfs and yarn users to include hadoop/bin in the PATH ",
:type => 'string'

attribute "hadoop/logging_level",
:description => "Log levels are: TRACE, DEBUG, INFO, WARN",
:type => 'string'

attribute "hadoop/nn/heap_size",
:description => "Size of the NameNode heap in MBs",
:type => 'string'

attribute "hadoop/nn/direct_memory_size",
:description => "Size of the direct memory size for the NameNode in MBs",
:type => 'string'

attribute "hadoop/ha_enabled",
:description => "'true' to enable HA, else 'false'",
:type => 'string'

attribute "hadoop/yarn/rt",
:display_name => "Hadoop Resource Tracker enabled on this nodegroup",
:type => 'string'
