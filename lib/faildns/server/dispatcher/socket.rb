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

class ConnectionDispatcher

class Socket
	attr_reader :ip, :port, :type

	def initialize (dispatcher, what)
		if what.is_a? TCPSocket
			@type = :tcp
			@ip   = what.peeraddr[3]
			@port = what.addr[1]

			@socket = what
		else
			@type = :udp
			@ip   = what[3]
			@port = what[1]

			@socket = UDPSocket.new
		end
	end

	def send (message, close = true)
		if @type == :udp && (tmp = message.pack).length > 512
			[message.additionals, message.authorities, message.answers, message.questions].each {|rr|
				while (tmp = message.pack).length > 512 && rr.pop; end

				break if tmp.length <= 512
			}

			message.header.questions   = message.questions.length
			message.header.answers     = message.answers.length
			message.header.authorities = message.authorities.length
			message.header.additionals = message.additionals.length

			message.header.truncated!

			data = message.pack
		else
			data = tmp
		end

		DNS.debug "[Server > #{to_s}] #{message.inspect}", level: 9, separator: "\n"

		if @socket.is_a? TCPSocket
			@socket.send_nonblock(data)

			@socket.close if close
		else
			@socket.send(data, 0, ::Socket.pack_sockaddr_in(@port, @ip))
		end
	end

	def close
		if type == :tcp
			@socket.close
		end
	end

	def to_s
		"#{@ip}:#{@port}"
	end

	def inspect
		"#<Socket: (#{@type}) #{@ip}:#{@port}>"
	end
end

end

end

end

end
