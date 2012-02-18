#--
# Copyleft meh. [http://meh.doesntexist.org | meh@paranoici.org]
#
# This file is part of faildns.
#
# faildns is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# faildns is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with faildns. If not, see <http://www.gnu.org/licenses/>.
#++

require 'faildns/version'

module DNS
	def self.debug (argument, options={})
		return unless ENV['FAILDNS_DEBUG']

		return if ENV['FAILDNS_DEBUG'].to_i < (options[:level] || 1)

		output = "[#{Time.new}] From: #{caller[0, options[:deep] || 1].join("\n")}\n"

		if argument.is_a?(Exception)
			output << "#{argument.class}: #{argument.message}\n"
			output << argument.backtrace.collect {|stack|
				stack
			}.join("\n")
			output << "\n\n"
		elsif argument.is_a?(String)
			output << "#{argument}\n"
		else
			output << "#{argument.inspect}\n"
		end

		if options[:separator]
			output << options[:separator]
		end

		puts output
	end

	module Comparable
		def self.included (klass)
			klass.instance_eval {
				define_singleton_method :hash_on do |*names|
					names = names.flatten.compact.map(&:to_s)

					define_method :hash do
						names.map {|name|
							if name.start_with? '@'
								instance_variable_get(name)
							else
								__send__(name)
							end
						}.hash
					end
				end
			}
		end

		def == (o)
			hash == o.hash
		end

		alias eql? ==

		def === (o)
			__id__ == o.__id__
		end
	end
end
