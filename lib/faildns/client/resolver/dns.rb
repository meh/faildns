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

require 'faildns/client/resolver/dns/server'

module DNS; class Client; module Resolver

class DNS
	attr_reader :servers

	def initialize (config_info = nil)
		if config_info.nil?
			@config = '/etc/resolv.conf'
		elsif config.is_a? String
			@config = config_info
		elsif config.is_a? Hash
			@config = config_info
		else
			raise ArgumentError, 'you have to pass a Hash or a String'
		end

		@servers = []

		if @config.is_a? String
			File.read(@config).lines.select { |l| l =~ /nameserver/ }.each {|line|
				@servers << Server.new(line.match(/nameserver\s+(.*?)$/)[1].strip)
			}
		else
			@config[:nameserver].each {|host|
				@servers << Server.new(host)
			}

			@config[:nameserver_port].each {|host, port|
				@servers << Server.new(host, port)
			}
		end
	end

	def query (message, options = nil)
		options = { timeout: 10 }.merge(options || {})
		result  = {}

		if message.is_a? Question
			message = Message.new {|m|
				m.header = Header.new {|h|
					h.recursive!
				}

				m.questions << message
			}
		end

		servers.each {|server|
			next if result[server.to_s]

			server.send(message)

			response = server.recv(message.header.id, options[:timeout])

			if response && (!options[:status] || options[:status].any? { |match| response.message.header.status == match })
				result[server.to_s] = response
			end

			break if options[:limit] && result.length >= options[:limit]
		}

		result
	end

	def resolve (domain, options = nil)
		options = { version: 4 }.merge(options || {})

		if options[:reverse]
			response = query(Question.new {|q|
				q.name  = domain.split('.').reverse.join('.') + '.in-addr.arpa'
				q.class = :IN
				q.type  = :PTR
			}, options.merge(limit: 1, status: [:NOERROR]))

			return if response.empty?

			response.values.map(&:message).map(&:answers).flatten.select {|answer|
				answer.type == :PTR
			}.map { |answer| answer.data.domain }.uniq
		else
			response = query(Question.new {|q|
				q.name  = domain
				q.class = :IN
				q.type  = ((options[:version] == 4) ? :A : :AAAA)
			}, options.merge(limit: 1, status: [:NOERROR, :NXDOMAIN]))

			response.dup.each {|name, r|
				response.delete(name) if r.message.header.status == :NXDOMAIN
			}

			return if response.empty?

			response.values.map(&:message).(&:answers).flatten.select {|answer|
				answer.type == ((options[:version] == 4) ? :A : :AAAA)
			}.map { |answer| answer.data.ip }.uniq
		end
	end
end

end; end; end
