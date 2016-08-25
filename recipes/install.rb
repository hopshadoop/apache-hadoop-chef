
case node.platform
when "ubuntu"
 if node.platform_version.to_f <= 14.04
   node.override.apache_hadoop.systemd = "false"
 end
end


if node.apache_hadoop.os_defaults == "true" then

  # http://blog.cloudera.com/blog/2015/01/how-to-deploy-apache-hadoop-clusters-like-a-boss/
  node.default.sysctl.allow_sysctl_conf = true
  node.default.sysctl.params.vm.swappiness = 1
  node.default.sysctl.params.vm.overcommit_memory = 1
  node.default.sysctl.params.vm.overcommit_ratio = 100
  node.default.sysctl.params.net.core.somaxconn= 1024
  include_recipe 'sysctl::apply'

  #
  # http://www.slideshare.net/vgogate/hadoop-configuration-performance-tuning
  #
  case node.platform_family
  when "debian"
    bash "configure_os" do
      user "root"
      code <<-EOF
   EOF
    end
  when "redhat"
    bash "configure_os" do
      user "root"
      code <<-EOF
      echo "never" > /sys/kernel/mm/redhat_transparent_hugepages/defrag
     EOF
    end
    
  end
  
end







include_recipe "java"


group node.apache_hadoop.group do
  action :create
  not_if "getent group #{node.apache_hadoop.group}"
end

user node.apache_hadoop.hdfs.user do
  supports :manage_home => true
  action :create
  home "/home/#{node.apache_hadoop.hdfs.user}"
  system true
  shell "/bin/bash"
  not_if "getent passwd #{node.apache_hadoop.hdfs.user}"
end

user node.apache_hadoop.yarn.user do
  supports :manage_home => true
  home "/home/#{node.apache_hadoop.yarn.user}"
  action :create
  system true
  shell "/bin/bash"
  not_if "getent passwd #{node.apache_hadoop.yarn.user}"
end

user node.apache_hadoop.mr.user do
  supports :manage_home => true
  home "/home/#{node.apache_hadoop.mr.user}"
  action :create
  system true
  shell "/bin/bash"
  not_if "getent passwd #{node.apache_hadoop.mr.user}"
end

group node.apache_hadoop.group do
  action :modify
  members ["#{node.apache_hadoop.hdfs.user}", "#{node.apache_hadoop.yarn.user}", "#{node.apache_hadoop.mr.user}"]
  append true
end

case node.platform_family
when "debian"
  package "openssh-server" do
    action :install
    options "--force-yes"
  end

  package "openssh-client" do
    action :install
    options "--force-yes"
  end
when "rhel"

end

if node.apache_hadoop.native_libraries.eql? "true" 

  # build hadoop native libraries: http://www.drweiwang.com/build-hadoop-native-libraries/
  # g++ autoconf automake libtool zlib1g-dev pkg-config libssl-dev cmake

  include_recipe 'build-essential::default'
  include_recipe 'cmake::default'

    protobuf_url = node.apache_hadoop.protobuf_url
    base_protobuf_filename = File.basename(protobuf_url)
    cached_protobuf_filename = "/tmp/#{base_protobuf_filename}"

    remote_file cached_protobuf_filename do
      source protobuf_url
      owner node.apache_hadoop.hdfs.user
      group node.apache_hadoop.group
      mode "0775"
      action :create_if_missing
    end

  protobuf_lib_prefix = "/usr"
  case node.platform_family
  when "debian"
    package "g++" do
      options "--force-yes"
    end
    package "autoconf" do
      options "--force-yes"
    end
    package "automake" do
      options "--force-yes"
    end
    package "libtool" do
      options "--force-yes"
    end
    package "zlib1g-dev" do
      options "--force-yes"
    end
    package "libssl-dev" do
      options "--force-yes"
    end
    package "pkg-config" do
      options "--force-yes"
    end
    package "maven" do
      options "--force-yes"
    end

  when "rhel"
  protobuf_lib_prefix = "/" 

# https://github.com/burtlo/ark
    ark "maven" do
      url "http://apache.mirrors.spacedump.net/maven/maven-3/#{node.maven.version}/binaries/apache-maven-#{node.maven.version}-bin.tar.gz"
      version "#{node.maven.version}"
      path "/usr/local/maven/"
      home_dir "/usr/local/maven"
 #     checksum  "#{node.maven.checksum}"
      append_env_path true
      owner "#{node.apache_hadoop.hdfs.user}"
    end
#    bash 'install-maven' do
#       user "root"
#       code <<-EOH
#         set -e
#        sudo wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
#        sudo sed -i s/\$releasever/6/g /etc/yum.repos.d/epel-apache-maven.repo
#         sudo yum install -y apache-maven
# 	EOH
#      not_if { ::File.exist?("/etc/yum.repos.d/epel-apache-maven.repo") }
#     end
       
  
  end
   protobuf_name_no_extension = File.basename(base_protobuf_filename, ".tar.gz")
   protobuf_name = "#{protobuf_lib_prefix}/.#{protobuf_name_no_extension}_downloaded"
   bash 'extract-protobuf' do
      user "root"
      code <<-EOH
        set -e
        cd /tmp
	tar -zxf #{cached_protobuf_filename} 
        cd #{protobuf_name_no_extension}
        ./configure --prefix=#{protobuf_lib_prefix}
        make
        make check
        make install
        touch #{protobuf_name}
	EOH
     not_if { ::File.exist?("#{protobuf_name}") }
    end

end

directory node.apache_hadoop.dir do
  owner node.apache_hadoop.hdfs.user
  group node.apache_hadoop.group
  mode "0774"
  recursive true
  action :create
  not_if { File.directory?("#{node.apache_hadoop.dir}") }
end

directory node.apache_hadoop.data_dir do
  owner node.apache_hadoop.hdfs.user
  group node.apache_hadoop.group
  mode "0774"
  recursive true
  action :create
end


directory node.apache_hadoop.dn.data_dir do
  owner node.apache_hadoop.hdfs.user
  group node.apache_hadoop.group
  mode "0774"
  recursive true
  action :create
end

directory node.apache_hadoop.nn.name_dir do
  owner node.apache_hadoop.hdfs.user
  group node.apache_hadoop.group
  mode "0774"
  recursive true
  action :create
end

primary_url = node.apache_hadoop.download_url.primary
secondary_url = node.apache_hadoop.download_url.secondary
Chef::Log.info "Attempting to download hadoop binaries from #{primary_url} or, alternatively, #{secondary_url}"

base_package_filename = File.basename(primary_url)
cached_package_filename = "/tmp/#{base_package_filename}"

remote_file cached_package_filename do
  source primary_url
  retries 2
  owner node.apache_hadoop.hdfs.user
  group node.apache_hadoop.group
  mode "0755"
  ignore_failure true
  # TODO - checksum
  action :create_if_missing
end

base_package_filename = File.basename(secondary_url)
cached_package_filename = "/tmp/#{base_package_filename}"

remote_file cached_package_filename do
  source secondary_url
  retries 2
  owner node.apache_hadoop.hdfs.user
  group node.apache_hadoop.group
  mode "0755"
  # TODO - checksum
  action :create_if_missing
  not_if { ::File.exist?(cached_package_filename) }
end

hin = "#{node.apache_hadoop.home}/.#{base_package_filename}_downloaded"
base_name = File.basename(base_package_filename, ".tar.gz")
# Extract and install hadoop
bash 'extract-hadoop' do
  user "root"
  code <<-EOH
	tar -zxf #{cached_package_filename} -C #{node.apache_hadoop.dir}
        ln -s #{node.apache_hadoop.dir}/#{node.apache_hadoop.version} #{node.apache_hadoop.base_dir}
        # chown -L : traverse symbolic links
        chown -RL #{node.apache_hadoop.hdfs.user}:#{node.apache_hadoop.group} #{node.apache_hadoop.home}
        chown -RL #{node.apache_hadoop.hdfs.user}:#{node.apache_hadoop.group} #{node.apache_hadoop.base_dir}
        # remove the config files that we would otherwise overwrite
        rm -f #{node.apache_hadoop.home}/etc/hadoop/yarn-site.xml
        rm -f #{node.apache_hadoop.home}/etc/hadoop/core-site.xml
        rm -f #{node.apache_hadoop.home}/etc/hadoop/hdfs-site.xml
        rm -f #{node.apache_hadoop.home}/etc/hadoop/mapred-site.xml
        touch #{hin}
        chown -RL #{node.apache_hadoop.hdfs.user}:#{node.apache_hadoop.group} #{node.apache_hadoop.home}
	EOH
  not_if { ::File.exist?("#{hin}") }
end


if node.apache_hadoop.native_libraries == "true" 

  hadoop_src_url = node.apache_hadoop.hadoop_src_url
  base_hadoop_src_filename = File.basename(hadoop_src_url)
  cached_hadoop_src_filename = "/tmp/#{base_hadoop_src_filename}"

  remote_file cached_hadoop_src_filename do
    source hadoop_src_url
    owner node.apache_hadoop.hdfs.user
    group node.apache_hadoop.group
    mode "0755"
    action :create_if_missing
  end

  hadoop_src_name = File.basename(base_hadoop_src_filename, ".tar.gz")
  natives="#{node.apache_hadoop.dir}/.downloaded_#{hadoop_src_name}"

  bash 'build-hadoop-from-src-with-native-libraries' do
    user node.apache_hadoop.hdfs.user
    code <<-EOH
        set -e
        cd /tmp
	tar -xf #{cached_hadoop_src_filename} 
        cd #{hadoop_src_name}
        mvn package -Pdist,native -DskipTests -Dtar
        cp -r hadoop-dist/target/hadoop-#{node.apache_hadoop.version}/lib/native/* #{node.apache_hadoop.home}/lib/native/
        chown -R #{node.apache_hadoop.hdfs.user} #{node.apache_hadoop.home}/lib/native/
        touch #{natives}
	EOH
    not_if { ::File.exist?("#{natives}") }
  end

end

 directory node.apache_hadoop.logs_dir do
   owner node.apache_hadoop.hdfs.user
   group node.apache_hadoop.group
   mode "0775"
   action :create
 end

 directory node.apache_hadoop.tmp_dir do
   owner node.apache_hadoop.hdfs.user
   group node.apache_hadoop.group
   mode "1777"
   action :create
 end

link node.apache_hadoop.base_dir do
  to node.apache_hadoop.home
end

include_recipe "apache_hadoop"


bash 'update_permissions_etc_dir' do
  user "root"
  code <<-EOH
    set -e
    chmod 775 #{node.apache_hadoop.conf_dir}
  EOH
end

if node.apache_hadoop.cgroups.eql? "true" 

  case node.platform_family
  when "debian"
    package "libcgroup-dev" do
    end

  when "redhat"

    # This doesnt work for rhel-7
    package "libcgroup" do
    end
  end
  cgroups_mounted= "/tmp/.cgroups_mounted"
  bash 'setup_mount_cgroups' do
    user "root"
    code <<-EOH
    set -e
    if [ ! -d "/cgroup" ] ; then
       mkdir /cgroup
    fi
    mount -t cgroup -o cpu cpu /cgroup
    touch #{cgroups_mounted}
  EOH
     not_if { ::File.exist?("#{cgroups_mounted}") }
  end

end

 directory "#{node.apache_hadoop.home}/journal" do
   owner node.apache_hadoop.hdfs.user
   group node.apache_hadoop.group
   mode "0775"
   action :create
 end
