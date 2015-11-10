Encoding.default_external = "UTF-8"
source 'https://supermarket.chef.io'
metadata

cookbook 'kagent', github: 'karamelchef/kagent-chef', branch: 'master'
cookbook 'java'

# Need to include these versions, or we get a 'chef-sugar' berks vendor error
cookbook 'openssh', "~> 1.3.4"
cookbook 'openssl', "~> 1.1.0"
#cookbook 'build-essential', '~> 1.3.2'
#cookbook 'cmake', '~> 0.3.0'
cookbook 'apt', '~> 2.6.0'
cookbook 'yum', '~> 3.4.0'
cookbook 'magic_shell', '~> 1.0'
cookbook 'ark'
cookbook 'ulimit', github: 'bmhatfield/chef-ulimit'
#cookbook 'sysctl', github: 'svanzoest-cookbooks/sysctl', version: 'v0.6.2'
#cookbook 'sysctl', '~> 0.6.2'

group :test do
  cookbook 'kzookeeper', github: 'hopshadoop/kzookeeper', branch: 'master'
  cookbook 'zookeeper', github: 'biobankcloud/chef-zookeeper', branch: 'master'
end
