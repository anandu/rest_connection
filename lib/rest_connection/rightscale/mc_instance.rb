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
class McInstance
  include RightScale::Api::Gateway
  extend RightScale::Api::GatewayExtend
  include RightScale::Api::McTaggable
  extend RightScale::Api::McTaggableExtend
  attr_accessor :monitoring_metrics
  
  def resource_plural_name
    "instances"
  end

  def resource_singular_name
    "instance"
  end

  def self.resource_plural_name
    "instances"
  end

  def self.resource_singular_name
    "instance"
  end
  
  def self.parse_args(cloud_id)
    "clouds/#{cloud_id}/"
  end
  
  def show
    inst_href = URI.parse(self.href)
    @params.merge! connection.get(inst_href.path, 'view' => "full")
  end

  def update
    inst_href = URI.parse(self.href)
    connection.put(inst_href.path, {"instance" => @params})
  end

  def launch
    inst_href = URI.parse(self.href)
    connection.post(inst_href.path + '/launch')
  end

  def terminate
    inst_href = URI.parse(self.href)
    connection.post(inst_href.path + '/terminate')
  end

  def multi_update(input_ary)
    inst_href = URI.parse(self.href)
    connection.put(inst_href.path + '/inputs/multi_update', {'inputs' => input_ary})
  end

  def transform_inputs(sym, parameters)
    ret = nil
    if parameters.is_a?(Array) and sym == :to_h
      ret = {}
      parameters.each { |hash| ret[hash['name']] = hash['value'] }
    elsif parameters.is_a?(Hash) and sym == :to_a
      ret = []
      parameters.each { |key,val| ret << {'name' => key, 'value' => val} }
    end
    ret
  end

  def translate_href(old_href)
    href = old_href.dup
    href.gsub!(/ec2_/,'')
    href.gsub!(/\/acct\/[0-9]*/,'')
    return href
  end

  def run_executable(executable, opts=nil)
    run_options = Hash.new
    if executable.is_a?(Executable)
      if executable.recipe?
        run_options[:recipe_name] = executable.recipe
      else
        run_options[:right_script_href] = translate_href(executable.right_script.href)
      end
    elsif executable.is_a?(RightScript)
      run_options[:right_script_href] = translate_href(executable.href)
    else
      raise "Invalid class passed to run_executable, needs Executable or RightScript, was:#{executable.class}"
    end

    inst_href = URI.parse(self.href)
    run_options[:inputs] = transform_inputs(:to_a, opts) unless opts.nil?
    location = connection.post(inst_href.path + '/run_executable', run_options)
    Task.new('href' => location)
  end

  def fetch_monitoring_metrics
    @monitoring_metrics = []
    return @monitoring_metrics if self.state != "operational"
    connection.get(URI.parse(self.href).path + '/monitoring_metrics').each { |mm|
      @monitoring_metrics << MonitoringMetric.new(mm)
    }
    @monitoring_metrics
  end

  def get_sketchy_data(params)
    metric = fetch_monitoring_metrics.detect { |mm| mm.plugin == params['plugin_name'] and mm.view == params['plugin_type'] }
    raise "Metric not found!" unless metric
    metric.data(params['start'], params['end'])
  end

  def reboot
    self.show
    connection.post(URI.parse(self.href).path + '/reboot')
  end
end
