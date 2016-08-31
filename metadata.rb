name             "apache_hadoop"
maintainer       "Jim Dowling"
maintainer_email "jdowling@kth.se"
license          "GPL 2.0"
description      'Installs/Configures the Apache Hadoop distribution'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.1"
source_url       "https://github.com/hopshadoop/apache-hadoop-chef"

#link:<a target='_blank' href='http://%host%:50070/'>Launch the WebUI for the NameNode</a>
recipe            "apache_hadoop::nn", "Installs a Hadoop NameNode"
recipe            "apache_hadoop::dn", "Installs a Hadoop DataNode"
#link:<a target='_blank' href='http://%host%:8088/'>Launch the WebUI for the ResourceManager</a>
recipe            "apache_hadoop::rm", "Installs a YARN ResourceManager"
recipe            "apache_hadoop::nm", "Installs a YARN NodeManager"
#link:<a target='_blank' href='http://%host%:50030/'>Launch the WebUI for the JobTracker</a>
#link:<a target='_blank' href='http://%host%:51111/'>Launch the WebUI for the HistoryServer</a>
recipe            "apache_hadoop::jhs", "Installs a MapReduce History Server for YARN"
recipe            "apache_hadoop::ps", "Installs a WebProxy Server for YARN"


depends 'kagent'
depends 'java'
depends 'sysctl'
depends 'cmake'

%w{ ubuntu debian rhel centos }.each do |os|
  supports os
end

attribute "java/jdk_version",
          :description =>  "Jdk version",
          :type => 'string'

attribute "java/install_flavor",
          :description =>  "Oracle (default) or openjdk",
          :type => 'string'

attribute "apache_hadoop/yarn/nm/memory_mbs",
          :description => "Apache_Hadoop NodeManager Memory in MB",
          :type => 'string'

attribute "apache_hadoop/yarn/vcores",
          :description => "Apache_Hadoop NodeManager Number of Virtual Cores",
          :type => 'string'

attribute "apache_hadoop/yarn/max_vcores",
          :description => "Hadoop NodeManager Maximum Virtual Cores per container",
          :type => 'string'

attribute "apache_hadoop/version",
          :description => "Version of apache_hadoop",
          :type => 'string'

attribute "apache_hadoop/num_replicas",
          :description => "Number of replicates for each file stored in HDFS",
          :type => 'string'

attribute "apache_hadoop/container_cleanup_delay_sec",
          :description => "The number of seconds container data is retained after termination",
          :type => 'string'

attribute "apache_hadoop/group",
          :description => "Group to run hdfs/yarn/mr as",
          :type => 'string'

attribute "apache_hadoop/yarn/user",
          :description => "Username to run yarn as",
          :type => 'string'

attribute "apache_hadoop/mr/user",
          :description => "Username to run mapReduce as",
          :type => 'string'

attribute "apache_hadoop/hdfs/user",
          :description => "Username to run hdfs as",
          :type => 'string'

attribute "apache_hadoop/format",
          :description => "Format HDFS, Run 'hdfs namenode -format",
          :type => 'string'

attribute "apache_hadoop/tmp_dir",
          :description => "The directory in which Hadoop stores temporary data, including container data",
          :type => 'string'

attribute "apache_hadoop/data_dir",
          :description => "The directory in which Hadoop's DataNodes store their data",
          :type => 'string'

attribute "apache_hadoop/yarn/nodemanager_hb_ms",
          :description => "Heartbeat Interval for NodeManager->ResourceManager in ms",
          :type => 'string'

attribute "apache_hadoop/container_cleanup_delay_sec",
          :description => "The number of seconds container data is retained after termination",
          :type => 'string'

attribute "apache_hadoop/rm/scheduler_class",
          :description => "Java Classname for the Yarn scheduler (fifo, capacity, fair)",
          :type => 'string'

attribute "apache_hadoop/rm/scheduler_capacity/calculator_class",
          :description => "Switch to DominantResourseCalculator for multiple resource scheduling",
          :type => 'string'

attribute "apache_hadoop/user_envs",
          :description => "Update the PATH environment variable for the hdfs and yarn users to include hadoop/bin in the PATH ",
          :type => 'string'

attribute "apache_hadoop/logging_level",
          :description => "Log levels are: TRACE, DEBUG, INFO, WARN",
          :type => 'string'

attribute "apache_hadoop/nn/heap_size",
          :description => "Size of the NameNode heap in MBs",
          :type => 'string'

attribute "apache_hadoop/nn/direct_memory_size",
          :description => "Size of the direct memory size for the NameNode in MBs",
          :type => 'string'

attribute "apache_hadoop/ha_enabled",
          :description => "'true' to enable HA, else 'false'",
          :type => 'string'

attribute "apache_hadoop/yarn/rt",
          :description => "Hadoop Resource Tracker enabled on this nodegroup",
          :type => 'string'

attribute "apache_hadoop/dir",
          :description => "Hadoop installation directory",
          :type => 'string'
