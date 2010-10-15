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

require 'faildns/server/dispatcher/event'

module DNS

class Server

class Dispatcher

class EventDispatcher
  attr_reader :server, :dispatcher

  def initialize (dispatcher)
    @server     = dispatcher.server
    @dispatcher = dispatcher

    @chains = {
      :input  => [],
      :output => [],

      :custom => {}
    }
  end

  def dispatch (chain, socket, message)
    @chains[chain].each {|callback|
      callback.call(socket, message)
    }
  end

  def fire (event, *args)
    (@chain[:custom][event] || []).each {|callback|
      begin
        if callback.call(*args) == false
          return false
        end
      rescue Exception => e
      end
    }
  end

  def observe (event, callback, priority=0)
    @chains[:custom][event].push((callback.is_a?(Event::Callback)) ? callback : Event::Callback.new(callback, priority))
  end

  def register (chain, callback, priority=0)
    @chains[chain].push((callback.is_a?(Event::Callback)) ? callback : Event::Callback.new(callback, priority))
  end
end

end

end

end
