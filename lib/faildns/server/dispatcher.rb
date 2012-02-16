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

module DNS

class Server

class Dispatcher
	attr_reader :server

	def initialize (server)
		@server = server

		@pipes     = IO.pipe
		@listening = []
		@sockets   = []

		@input  = []
		@output = []
	end

	def listen (host, port = 53, type = :udp)
		@listening.push(if type == :upd
			socket = UDPSocket.new
			socket.bind(host, port)

			socket
		elsif type == :tcp
			TCPServer.new(host, port)
		end)
	end

	def handle (string, socket)
		server.do(string, socket) {|string, socket|
			begin
				socket  = Socket.new(self, socket)
				message = Message.parse(string)

				DNS.debug "[Server < #{socket.to_s}] #{message.inspect}", level: 9, separator: "\n"

				input socket, message
			rescue Exception => e
				DNS.debug e
			end
		}
	end

	def start
		@running = true

		self.loop
	end

	def stop
		@running = false

		wakeup
	end

	def running?
		!!@running
	end

	def loop
		self.do while running?
	end

	def do
		begin
			reading, _, erroring = IO.select(@listening + @sockets, nil, @listening + @sockets)
		rescue Errno::EBADF
			return
		end

		erroring.each {|socket|
			if socket == @pipes.first
				socket.read_nonblock(2048) rescue nil
			elsif @sockets.include? socket
				@sockets.delete socket
			elsif @listening.include? socket
				raise 'listening socket exploded'
			end
		}

		reading.each {|socket|
			begin
				if socket.is_a? TCPServer
					@sockets.push socket.accept_nonblock
				elsif socket.is_a? TCPSocket
					handle socket.recv_nonblock(65535), socket
				else
					handle *socket.recvfrom_nonblock(512)
				end
			rescue Errno::EAGAIN; end
		}
	end

	def wakeup
		@pipes.last.write '?'
	end
end

end

end
