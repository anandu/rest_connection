require 'rubygems'
require 'rest_connection'
require 'trollop'

opts = Trollop::options do
  opt :deployment, "deployment nickname", :type => :string, :required => true
  opt :template, "server template href to set for all servers", :type => :string, :required => true
end

deployment = Deployment.find_by_nickname_speed(opts[:deployment]).first

deployment.servers.each do |s|
  s.set_template(opts[:template])
end
