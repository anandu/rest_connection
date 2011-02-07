#    This file is part of RestConnection 
#
#    RestConnection is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    RestConnection is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with RestConnection.  If not, see <http://www.gnu.org/licenses/>.

class Deployment
  include RightScale::Api::Base
  extend RightScale::Api::BaseExtend

  def reload
    uri = URI.parse(self.href)
    @params ? @params.merge!(connection.get(uri.path)) : @params = connection.get(uri.path)
    @params['cloud_id'] = cloud_id
    @params
  end

  def cloud_id
    @cloud_id = self.nickname.match(/cloud_[0-9]+/)[0].match(/[0-9]+/)[0].to_i unless @cloud_id
    @cloud_id
  end

  def self.create(opts)
    location = connection.post(self.resource_plural_name, self.resource_singular_name.to_sym => opts)
    newrecord = self.new('href' => location)
    newrecord.reload
    newrecord
  end

  def set_inputs(hash = {})
    deploy_href = URI.parse(self.href)
    connection.put(deploy_href.path, :deployment => {:parameters => hash })
  end

  def set_input(name, value)
    deploy_href = URI.parse(self.href)
    connection.put(deploy_href.path, :deployment => {:parameters => {name => value} })
  end

  def servers_no_reload
    @params['servers'].map { |s| ServerInterface.new(cloud_id, s) }
  end

  def servers
    # this populates extra information about the servers
    servers_no_reload.each do |s|
      s.reload
    end
  end

  def duplicate
    clone
  end

  def clone
    deploy_href = URI.parse(@deploy.href)
    Deployment.new(:href => connection.post(deploy_href.path + "/duplicate"))
  end
end
