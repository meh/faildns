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
			@resolvers << server.is_a?(String) ? Resolver::DNS.new(server) : server
		}

		yield self if block_given?
	end

	def servers
		@resolvers.select { |r| r.respond_to? :query }
	end

	def query (message, options = nil)
		servers.reduce({}) {|result, server|
			result.merge(server.query(message, options))
		}
	end

	def resolve (domain, options = nil)
		resolvers.reduce([]) {|result, resolver|
			result + resolver.resolve(domain, options)
		}
	end

	def inspect
		"#<DNS::Client: #{resolvers.map(&:inspect).join ' '}>"
	end
end

end
