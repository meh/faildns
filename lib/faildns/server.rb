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

require 'faildns/common'
require 'faildns/server/dispatcher'

module DNS

class Server
  attr_reader :options, :dispatcher

  def initialize (options={})
    if !options.is_a? Hash
      raise ArgumentError.new('You have to pass a Hash')
    end

    @options = options

    @dispatcher = Dispatcher.new(self)

    if block_given?
      yield self
    end
  end

  def start
    if @started
      return
    end

    @started = true

    @dispatcher.start
  end

  def stopping
    @stopping = true

    @dispatcher.stop
  end

  def register (*args)
    @dispatcher.event.register(*args)
  end

  def observe (*args)
    @dispatcher.event.observe(*args)
  end

  def fire (*args)
    @dispatcher.event.fire(*args)
  end
end

end
