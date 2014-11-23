name             'hadoop'
maintainer       "Jim Dowling"
maintainer_email "jdowling@kth.se"
license          "GPL 2.0"
description      'Installs/Configures the Apache Hadoop distribution'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "1.0"

recipe            "hadoop::nn", "Installs a Hadoop Namenode"
recipe            "hadoop::dn", "Installs a Hadoop Namenode"
recipe            "hadoop::rm", "Installs a YARN ResourceManager"
recipe            "hadoop::nm", "Installs a YARN NodeManager"
recipe            "hadoop::jhs", "Installs a MapReduce History Server for YARN"
recipe            "hadoop::ps", "Installs a WebProxy Server for YARN"


depends 'kagent'
depends 'java'
depends 'cmake'
depends 'apt'
depends 'yum'
depends 'build-essential'
depends 'ark'

%w{ ubuntu debian rhel centos }.each do |os|
  supports os
end

attribute "hadoop/version",
:display_name => "Hadoop version",
:description => "Version of hadoop",
:type => 'string',
:default => "2.4.0"


attribute "hadoop/namenode/addrs",
:display_name => "Namenode ip addresses (comma-separated)",
:description => "A comma-separated list of Namenode ip address",
:type => 'array',
:default => ""

attribute "yarn/resourcemanager",
:display_name => "Ip address",
:description => "Ip address for the resourcemanager",
:type => 'string',
:default => ""

attribute "hadoop/user",
:display_name => "Username to run hadoop as",
:description => "Username to run hadoop as",
:type => 'string',
:default => ""

attribute "hadoop/format",
:display_name => "Format HDFS",
:description => "Format HDFS, Run 'hdfs namenode -format'",
:type => 'string',
:default => "true"

