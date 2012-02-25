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

module DNS; class Server; class Dispatcher

class Client < EM::Connection
	attr_reader :dispatcher, :ip, :port, :type

	def post_init
		@ip   = Socket.unpack_sockaddr_in(get_peername).last
		@port = Socket.unpack_sockaddr_in(get_sockname).first
	end

	def receive_data (data)
		message  = Message.unpack(data)
		response = Message.new

		dispatcher.input  message, response
		dispatcher.output response

		send_message response
	ensure
		close_connection_after_writing
	end

	def send_message (message)
		if type == :udp && (tmp = message.pack).length > 512
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

		send_data(data)
	end

	def to_s
		"#{@ip}:#{@port}"
	end

	def inspect
		"#<Socket: (#{@type}) #{@ip}:#{@port}>"
	end
end

end; end; end
