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

class Server
	attr_reader :dispatcher, :type, :host, :port

	def initialize (dispatcher, type, host, port)
		@dispatcher = dispatcher

		@type = type
		@host = host
		@port = port
	end

	def start
		dispatcher = @dispatcher

		@signature = if type == :tcp
			EM.start_server host, port, Client do |client|
				client.instance_eval {
					@dispatcher = dispatcher

					@type = :tcp
				}
			end
		else
			EM.open_datagram_socket host, port, Client do |client|
				client.instance_eval {
					@dispatcher = dispatcher

					@type = :udp
				}
			end
		end
	end

	def stop
		EM.stop_server @signature
	end
end

end; end; end
