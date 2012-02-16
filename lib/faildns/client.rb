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

require 'faildns/message'

require 'faildns/client/dispatcher'

module DNS

class Client
	attr_reader :options

	def initialize (options = {})
		@options    = options
		@dispatcher = Dispatcher.new([@options[:servers]].flatten.compact)

		if block_given?
			yield self
		end

		if @dispatcher.servers.empty?
			if File.readable?('/etc/resolv.conf')
				File.read('/etc/resolv.conf').lines.each {|line|
					line.match(/nameserver\s+(.*?)\s*$/) {
						@dispatcher.servers << $1
					}
				}
			end
		end
	end

	def servers
		@dispatcher.servers
	end

	def query (message, options = nil)
		options = { timeout: 10, tries: 3 }.merge(options || {})
		result  = {}

		if message.is_a? Question
			message = Message.new {|m|
				m.header = Header.new {|h|
					h.recursive!

					h.questions = 1
				}

				m.questions << message
			}
		end

		1.upto(options[:tries]) {
			servers.each {|server|
				next if result[server.to_s]

				begin
					server.send(message)

					response = server.recv(message.header.id, options[:timeout])

					if response && (!options[:status] || options[:status].any? { |match| response.message.header.status == match })
						result[server.to_s] = response
					end
				rescue Exception => e
					DNS.debug e
				end

				break if options[:limit] && result.length >= options[:limit]
			}

			break if result.length == options[:limit] || result.length == self.servers.length
		}

		result
	end

	def resolve (domain, options = nil)
		options = { version: 4 }.merge(options || {})

		response = query(Question.new {|q|
			q.name  = domain
			q.class = :IN
			q.type  = ((options[:version] == 4) ? :A : :AAAA)
		}, options.merge(limit: 1, status: [:NOERROR])).first.last.message.answers.select {|answer|
			answer.type == ((options[:version] == 4) ? :A : :AAAA)
		}.map {|answer|
			answer.data.ip
		}
	end

	def inspect
		"#<Client: #{servers.inspect}>"
	end
end

end
