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

require 'faildns'
require 'faildns/client/resolver'

module DNS

class Client
	attr_reader :options, :resolvers

	def initialize (options = {})
		@options   = options
		@resolvers = []
		
		([@options[:servers]] + [@options[:resolvers]]).flatten.compact.each {|server|
			@resolvers << if server.is_a?(String) || server.is_a?(Hash)
				Resolver::DNS.new(server)
			else
				server
			end
		}

		if @resolvers.empty? && @options[:servers] != false && @options[:resolvers] != false
			@resolvers << Resolver::Hosts.new
			@resolvers << Resolver::DNS.new
		end

		yield self if block_given?
	end

	def servers
		@resolvers.select { |r| r.respond_to? :query }
	end

	def query (message = nil, options = nil, &block)
		options = { timeout: 10, single_timeout: 5 }.merge(options || {})
		result  = {}

		begin
			Timeout.timeout(options[:timeout]) {
				servers.each {|server|
					result.merge!(server.query(message, options.merge(timeout: options[:single_timeout]), &block))
				}
			}
		rescue Timeout::Error; end

		result.empty? ? nil : result
	end

	def resolve (domain, options = nil)
		options = { timeout: 10, single_timeout: 5 }.merge(options || {})
		result  = []

		begin
			Timeout.timeout(options[:timeout]) {
				resolvers.each {|resolver|
					result.concat(resolver.resolve(domain, options.merge(timeout: options[:single_timeout])) || [])
				}
			}
		rescue Timeout::Error; end

		resolvers.compact!
		resolvers.uniq!

		result.empty? ? nil : result
	end

	def inspect
		"#<DNS::Client: #{resolvers.map(&:inspect).join ' '}>"
	end
end

end
