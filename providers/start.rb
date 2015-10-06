action :start_if_not_running do
  bash "start-if-not-running-#{new_resource.name}" do
    user "root"
    code <<-EOH
     set -e
  #  service status returns '0' even if the service is not running ;(
  #   if [ `service #{new_resource.name} status` -ne 0 ] ; then
         service #{new_resource.name} restart
 #    fi 
    EOH
  end

end


action :format_nn do
  if  "#{new_resource.ha_enabled}".eql? "true"
    bash 'format-nn-ha' do
      user node[:hdfs][:user]
      code <<-EOH
        set -e
        #{node[:hadoop][:home]}/bin/hdfs zkfc -formatZK -force
 	EOH
    end
  end
    bash 'format-nn' do
      user node[:hdfs][:user]
      code <<-EOH
        set -e
        #{node[:hadoop][:home]}/sbin/format-nn.sh
        touch #{node[:hadoop][:home]}/.nn_formatted
 	EOH
    end

end

action :zkfc do
  if  "#{new_resource.ha_enabled}".eql? "true"
    bash 'zookeeper-format' do
      user node[:hdfs][:user]
      code <<-EOH
        set -e
        #{node[:hadoop][:home]}/bin/hdfs zkfc -formatZK -force
 	EOH
    end
  end
end

action :standby do
  if  "#{new_resource.ha_enabled}".eql? "true"
    bash 'standby' do
      user node[:hdfs][:user]
      code <<-EOH
        set -e
        #{node[:hadoop][:home]}/sbin/start-standby-nn.sh
 	EOH
    end
  end
end
