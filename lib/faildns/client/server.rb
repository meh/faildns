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

require 'thread'
require 'timeout'
require 'socket'

require 'faildns/client/response'

module DNS; class Client

class Server
	attr_reader :host, :port

	def initialize (host, port=53)
		@host = host
		@port = port

		@socket = UDPSocket.new
		@socket.connect(@host, @port)

		@requests  = {}
		@responses = {}

		@mutex = Mutex.new
	end

	def send (message)
		@requests[message.header.id] = true

		DNS.debug "[Client > #{self.to_s}] #{message.inspect}", level: 9, separator: "\n"

		@socket.print message.pack
	end

	def recv (id, timeout = 10)
		if id.is_a? Message
			id = id.header.id
		elsif id.is_a? Header
			id = id.id
		end

		if !@responses.has_key? id
			@mutex.synchronize {
				if !@responses.has_key? id
					_recv(timeout, id)
				end
			}
		end

		if (response = @responses.delete(id))
			DNS.debug "[Client < #{self.to_s}] #{response.message.inspect rescue nil}", level: 9, separator: "\n"
		end

		return response
	end

	def to_s
		"#{@host}#{":#{@port}" if @port != 53}"
	end

private
	def _recv (timeout, id = nil)
		Timeout.timeout(timeout) {
			while (msg = @socket.recvfrom(512) rescue nil)
				message = Message.unpack(msg[0])

				if @requests.delete(message.header.id)
					@responses[message.header.id] = Response.new(self, message)
				end

				break if id == message.header.id
			end
		}
	rescue Timeout::Error
	end
end

end; end
