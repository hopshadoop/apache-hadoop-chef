actions :create

attribute :name, :kind_of => String, :name_attribute => true
attribute :mode, :kind_of => String, :default => "0770"
attribute :owner, :kind_of => String, :default => "mapred"
attribute :group, :kind_of => String, :default => "hadoop"

default_action :create
