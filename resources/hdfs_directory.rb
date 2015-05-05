actions :create, :put

attribute :name, :kind_of => String, :name_attribute => true
attribute :mode, :kind_of => String, :default => ""
attribute :owner, :kind_of => String, :default => "mapred"
attribute :group, :kind_of => String, :default => "hadoop"
attribute :dest, :kind_of => String, :default => ""

default_action :create
