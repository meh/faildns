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

require 'eventmachine'

require 'faildns/server/dispatcher/server'
require 'faildns/server/dispatcher/client'

module DNS; class Server

class Dispatcher
	attr_reader :server, :listens_on

	def initialize (server)
		@server = server

		@listens_on = []

		@input  = []
		@output = []
	end

	def input (*args, &block)
		if block
			@input.push(block)
		else
			@input.each { |b| b.call(*args) }
		end
	end

	def output (*args, &block)
		if block
			@output.push(block)
		else
			@output.each { |b| b.call(*args) }
		end
	end

	def listen (type = :upd, host, port)
		server = Server.new(self, type, host, port)

		@listens_on.push server

		if running?
			EM.schedule {
				server.start
			}
		end
	end

	def running?; @running; end

	def start
		@running = true

		@listens_on.each(&:start)
	end

	def stop
		@listens_on.each(&:stop)

		@running = false
	end
end

end; end
