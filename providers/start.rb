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


action :format_nn

    bash 'format-nn' do
      user node[:hdfs][:user]
      code <<-EOH
        set -e
        	#{node[:hadoop][:home]}/sbin/format-nn.sh
 	EOH
    end

end
