libpath = File.expand_path '../../../kagent/libraries', __FILE__
require File.join(libpath, 'inifile')


node.default['java']['jdk_version'] = 7
# node.default['java']['install_flavor'] = "openjdk"
#include_recipe "openssh"
#node.default['java']['install_flavor'] = "oracle"
#node.default['java']['oracle']['accept_oracle_download_terms'] = true
include_recipe "java"

kagent_bouncycastle "jar" do
end

group node[:hadoop][:group] do
  action :create
end

user node[:hdfs][:user] do
  supports :manage_home => true
  action :create
  home "/home/#{node[:hdfs][:user]}"
  system true
  shell "/bin/bash"
end

group node[:hadoop][:group] do
  action :modify
  members node[:hdfs][:user]
  append true
end

case node[:platform_family]
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

if node[:hadoop][:native_libraries].eql? "true" 

  # build hadoop native libraries: http://www.drweiwang.com/build-hadoop-native-libraries/
  # g++ autoconf automake libtool zlib1g-dev pkg-config libssl-dev cmake

  include_recipe 'build-essential::default'
  include_recipe 'cmake::default'

    protobuf_url = node[:hadoop][:protobuf_url]
    base_protobuf_filename = File.basename(protobuf_url)
    cached_protobuf_filename = "#{Chef::Config[:file_cache_path]}/#{base_protobuf_filename}"

    remote_file cached_protobuf_filename do
      source protobuf_url
      owner node[:hdfs][:user]
      group node[:hadoop][:group]
      mode "0755"
      action :create_if_missing
    end

    protobuf_name = File.basename(base_protobuf_filename, ".tar.gz")
    bash 'extract-protobuf' do
      user "root"
      code <<-EOH
        cd #{Chef::Config[:file_cache_path]}
	tar -zxf #{cached_protobuf_filename} 
        cd #{protobuf_name}
        ./configure --prefix=/usr
        make
        make check
        make install
        touch /tmp/.downloaded_#{protobuf_name}
	EOH
      not_if { ::File.exist?("/tmp/.downloaded_#{protobuf_name}") }
     end

  case node[:platform_family]
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
  
    bash 'install_maven' do
      user "root"
      code <<-EOH
        set -e
        cd #{Chef::Config[:file_cache_path]}
        wget http://apache.mirrors.spacedump.net/maven/maven-3/#{node[:maven][:version]}/binaries/apache-maven-#{node[:maven][:version]}-bin.tar.gz
        tar xvf apache-maven-#{node[:maven][:version]}-bin.tar.gz
        mv -f apache-maven-#{node[:maven][:version]} /usr/local
        rm -f /usr/local/maven
        ln -s /usr/local/apache-maven-#{node[:maven][:version]} /usr/local/maven
        chown -R #{node[:hdfs][:user]}:#{node[:hadoop][:group]} /usr/local/maven
        # echo "export M2_HOME=/usr/local/maven" > /root/profile.d/maven.sh
        # echo "\n" > /root/profile.d/maven.sh
        # echo "export M2=$M2_HOME/bin " >>  /root/profile.d/maven.sh
        # echo "\n" > /root/profile.d/maven.sh
        # echo "export PATH=$M2:$PATH " >> /root/profile.d/maven.sh
        # echo "\n" > /root/profile.d/maven.sh
	EOH
      not_if { ::File.exist?("/tmp/.downloaded_maven_#{node[:maven][:version]}") }
     end
  end

  magic_shell_environment 'PATH' do 
     value "$PATH:" +  '/usr/local/maven/bin'
  end 
  magic_shell_environment 'PATH' do 
     value "M2_HOME:" +  '/usr/local/maven'
  end 
end


directory node[:hadoop][:dir] do
  owner node[:hdfs][:user]
  group node[:hadoop][:group]
  mode "0755"
  recursive true
  action :create
end

package_url = node[:hadoop][:download_url]
Chef::Log.info "Downloading hadoop binaries from #{package_url}"
base_package_filename = File.basename(package_url)
cached_package_filename = "#{Chef::Config[:file_cache_path]}/#{base_package_filename}"

remote_file cached_package_filename do
  source package_url
  owner node[:hdfs][:user]
  group node[:hadoop][:group]
  mode "0755"
  # TODO - checksum
  action :create_if_missing
end

hin = "#{node[:hadoop][:home]}/.#{base_package_filename}_downloaded"
base_name = File.basename(base_package_filename, ".tgz")
# Extract and install hadoop
bash 'extract-hadoop' do
  user "root"
  code <<-EOH
	tar -zxf #{cached_package_filename} -C #{node[:hadoop][:dir]}
# chown -L : traverse symbolic links
        chown -RL #{node[:hdfs][:user]}:#{node[:hadoop][:group]} #{node[:hadoop][:home]}
        touch #{hin}
	EOH
  not_if { ::File.exist?("#{hin}") }
end


if node[:hadoop][:native_libraries] == "true" 

  hadoop_src_url = node[:hadoop][:hadoop_src_url]
  base_hadoop_src_filename = File.basename(hadoop_src_url)
  cached_hadoop_src_filename = "#{Chef::Config[:file_cache_path]}/#{base_hadoop_src_filename}"

  remote_file cached_hadoop_src_filename do
    source hadoop_src_url
    owner node[:hdfs][:user]
    group node[:hadoop][:group]
    mode "0755"
    action :create_if_missing
  end

  hadoop_src_name = File.basename(base_hadoop_src_filename, ".tar.gz")
  natives="#{node[:hadoop][:dir]}/.downloaded_#{hadoop_src_name}"

  bash 'extract-hadoop-src' do
    user "root"
    code <<-EOH
        cd #{Chef::Config[:file_cache_path]}
	tar -xf #{cached_hadoop_src_filename} 
        cd #{hadoop_src_name}
        mvn package -Pdist,native -DskipTests -Dtar
        cp -r hadoop-dist/target/hadoop-#{node[:hadoop][:version]}/lib/* #{node[:hadoop][:home]}/lib/native
        touch #{natives}
	EOH
    not_if { ::File.exist?("#{natives}") }
  end

end

 directory node[:hadoop][:logs_dir] do
   owner node[:hdfs][:user]
   group node[:hadoop][:group]
   mode "0755"
   action :create
 end

 directory node[:hadoop][:tmp_dir] do
   owner node[:hdfs][:user]
   group node[:hadoop][:group]
   mode "0755"
   action :create
 end

link "#{node[:hadoop][:dir]}/hadoop" do
  to node[:hadoop][:home]
end
include_recipe "hadoop"
