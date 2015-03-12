libpath = File.expand_path '../../../kagent/libraries', __FILE__

my_private_ip = my_private_ip()
my_public_ip = my_public_ip()

# TODO - if multiple RMs, and node[:yarn][:rm][:addrs] is set because
# RMs are in different node groups, then use the attribute. Else
# use the private_ips


