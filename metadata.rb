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
depends 'magic_shell'

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

attribute "apache_hadoop/hdfs/blocksize",
          :description => "HDFS Blocksize (128k, 512m, 1g, etc). Default 128m.",
          :type => 'string'

attribute "apache_hadoop/format",
          :description => "Format HDFS, Run 'hdfs namenode -format",
          :type => 'string'

attribute "apache_hadoop/tmp_dir",
          :description => "The directory in which Hadoop stores temporary data, including container data",
          :type => 'string'

attribute "apache_hadoop/data_dir",
          :description => "The directory in which Hadoop's NameNodes and DataNodes store their data",
          :type => 'string'

attribute "apache_hadoop/dn/data_dir",
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

attribute "apache_hadoop/yarn/aux_services",
          :description => "mapreduce_shuffle, spark_shuffle",
          :type => "string"

attribute "apache_hadoop/nm/log_dir",
          :description => "Directory for storing user logs for the nodemanager",
          :type => 'string'

attribute "apache_hadoop/capacity/max_ap",
          :description => "Maximum number of applications that can be pending and running.",
          :type => "string"
attribute "apache_hadoop/capacity/max_am_percent",
          :description => "Maximum percent of resources in the cluster which can be used to run application masters i.e. controls number of concurrent running applications.",
          :type => "string"
attribute "apache_hadoop/capacity/resource_calculator_class",
          :description => "The ResourceCalculator implementation to be used to compare Resources in the scheduler. The default i.e. DefaultResourceCalculator only uses Memory while DominantResourceCalculator uses dominant-resource to compare multi-dimensional resources such as Memory, CPU etc.",
          :type => "string"
attribute "apache_hadoop/capacity/root/queues",
          :description => "The queues at the root level (root is the root queue).",
          :type => "string"
attribute "apache_hadoop/capacity/default_capacity",
          :description => "Default queue target capacity.",
          :type => "string"
attribute "apache_hadoop/capacity/user_limit_factor",
          :description => " Default queue user limit a percentage from 0.0 to 1.0.",
          :type => "string"
attribute "apache_hadoop/capacity/default_max_capacity",
          :description => "The maximum capacity of the default queue.",
          :type => "string"
attribute "apache_hadoop/capacity/default_state",
          :description => "The state of the default queue. State can be one of RUNNING or STOPPED.",
          :type => "string"
attribute "apache_hadoop/capacity/default_acl_submit_applications",
          :description => "The ACL of who can submit jobs to the default queue.",
          :type => "string"
attribute "apache_hadoop/capacity/default_acl_administer_queue",
          :description => "The ACL of who can administer jobs on the default queue.",
          :type => "string"
attribute "apache_hadoop/capacity/queue_mapping",
          :description => "A list of mappings that will be used to assign jobs to queues The syntax for this list is [u|g]:[name]:[queue_name][,next mapping]* Typically this list will be used to map users to queues, for example, u:%user:%user maps all users to queues with the same name as the user.",
          :type => "string"
attribute "apache_hadoop/capacity/queue_mapping_override.enable",
          :description => "If a queue mapping is present, will it override the value specified by the user? This can be used by administrators to place jobs in queues that are different than the one specified by the user. The default is false.",
          :type => "string"
          
