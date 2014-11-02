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

user node[:hadoop][:user] do
  supports :manage_home => true
  action :create
  home "/home/#{node[:hadoop][:user]}"
  system true
  shell "/bin/bash"
end

group node[:hadoop][:group] do
  action :modify
  members node[:hadoop][:user]
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

if node[:hadoop][:native_libraries] == "true" 

  # build hadoop native libraries: http://www.drweiwang.com/build-hadoop-native-libraries/
  # g++ autoconf automake libtool zlib1g-dev pkg-config libssl-dev cmake

  include_recipe 'build-essential::default'
  include_recipe 'cmake::default'

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
    package "protobuf-compiler" do
      options "--force-yes"
    end

  when "rhel"
    # TODO



    protobuf_url = node[:hadoop][:protobuf_url]
    base_protobuf_filename = File.basename(protobuf_url)
    cached_protobuf_filename = "#{Chef::Config[:file_cache_path]}/#{base_protobuf_filename}"

    remote_file cached_protobuf_filename do
      source protobuf_url
      owner node[:hadoop][:user]
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


  end

end


directory node[:hadoop][:dir] do
  owner node[:hadoop][:user]
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
  owner node[:hadoop][:user]
  group node[:hadoop][:group]
  mode "0755"
  # TODO - checksum
  action :create_if_missing
end

base_name = File.basename(base_package_filename, ".tgz")
# Extract and install hadoop
bash 'extract-hadoop' do
  user "root"
  code <<-EOH
	tar -zxf #{cached_package_filename} -C #{node[:hadoop][:dir]}
# chown -L : traverse symbolic links
        chown -RL #{node[:hadoop][:user]}:#{node[:hadoop][:group]} #{node[:hadoop][:home]}
        touch #{node[:hadoop][:home]}/.downloaded
	EOH
  not_if { ::File.exist?("#{node[:hadoop][:home]}/.downloaded") }
end


if node[:hadoop][:native_libraries] == "true" 

hadoop_src_url = node[:hadoop][:hadoop_src_url]
base_hadoop_src_filename = File.basename(hadoop_src_url)
cached_hadoop_src_filename = "#{Chef::Config[:file_cache_path]}/#{base_hadoop_src_filename}"

remote_file cached_hadoop_src_filename do
  source hadoop_src_url
  owner node[:hadoop][:user]
  group node[:hadoop][:group]
  mode "0755"
  action :create_if_missing
end

hadoop_src_name = File.basename(base_hadoop_src_filename, ".tar.gz")
natives="#{Chef::Config[:file_cache_path]}/.downloaded_#{hadoop_src_name}"

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
   owner node[:hadoop][:user]
   group node[:hadoop][:group]
   mode "0755"
   action :create
 end

 directory node[:hadoop][:tmp_dir] do
   owner node[:hadoop][:user]
   group node[:hadoop][:group]
   mode "0755"
   action :create
 end

link "#{node[:hadoop][:dir]}/hadoop" do
  to node[:hadoop][:home]
end
include_recipe "hadoop"
