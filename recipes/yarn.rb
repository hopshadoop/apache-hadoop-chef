
# TODO - if multiple RMs, and node[:yarn][:rm][:addrs] is set because
# RMs are in different node groups, then use the attribute. Else
# use the private_ips


case node.platform
when "ubuntu"
 if node.platform_version.to_f <= 14.04
   node.override.apache_hadoop.systemd = "false"
 end
end

