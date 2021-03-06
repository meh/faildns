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
require 'forwardable'

require 'faildns/server/dispatcher'

module DNS

class Server
	extend Forwardable

	attr_reader    :options, :dispatcher
	def_delegators :@dispatcher, :listen, :input, :output

	def initialize (options = {})
		unless options.is_a? Hash
			raise ArgumentError, 'you have to pass a Hash'
		end

		@options    = options
		@dispatcher = Dispatcher.new(self)

		yield self if block_given?
	end

	def start
		return if @started

		@started = true

		@dispatcher.start
	end

	def stopping
		@stopping = true

		@dispatcher.stop
	end
end

end
