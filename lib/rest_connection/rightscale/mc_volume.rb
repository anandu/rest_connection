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

#
# You must have Beta v1.5 API access to use these internal API calls.
#
class McVolume
  include RightScale::Api::Gateway
  extend RightScale::Api::GatewayExtend
  include RightScale::Api::McTaggable
  extend RightScale::Api::McTaggableExtend

  deny_methods :update

  def resource_plural_name
    "volumes"
  end

  def resource_singular_name
    "volume"
  end

  def self.resource_plural_name
    "volumes"
  end

  def self.resource_singular_name
    "volume"
  end

  def self.parse_args(cloud_id)
    "clouds/#{cloud_id}/"
  end

  def self.filters
    [:datacenter_href, :description, :name, :parent_volume_snapshot_href, :resource_uid]
  end

  def show
    inst_href = URI.parse(self.href)
    @params.merge! connection.get(inst_href.path, 'view' => 'extended')
  end

  def attachment
    connection.get(self.current_volume_attachment)
  end
end
