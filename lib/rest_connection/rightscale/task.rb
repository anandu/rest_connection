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
class Task
  include RightScale::Api::Gateway
  extend RightScale::Api::GatewayExtend
  
  def self.parse_args(cloud_id, instance_id)
    "clouds/#{cloud_id}/instances/#{instance_id}/live/"
  end

  def wait_for_state(state, timeout=900)
    while(timeout > 0)
      reload
      connection.logger("state is #{self.summary}, waiting for #{state}")
      raise "FATAL error, #{self.summary}\n" if self.summary.include?('failed')
      sleep 30
      timeout -= 30
      return true if self.summary.include?(state)
    end
    raise "FATAL: Timeout waiting for Executable to complete.  State was #{self.state}" if timeout <= 0
  end

  def wait_for_completed(legacy=nil)
    wait_for_state("completed")
  end
end
