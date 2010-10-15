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

require 'faildns/server/dispatcher/connectiondispatcher'
require 'faildns/server/dispatcher/eventdispatcher'

module DNS

class Server

class Dispatcher
  attr_reader :server, :connection, :event

  def initialize (server)
    @server = server

    @connection = ConnectionDispatcher.new(self)
    @event      = EventDispatcher.new(self)

    @intervals = {}
    @timeouts  = {}
  end

  def start
    @connection.start

    @started = true

    @listening = Fiber.new {
      while true
        @connection.accept

        Fiber.yield
      end
    }

    @reading = Fiber.new {
      while true
        @connection.read

        Fiber.yield
      end
    }

    @handling = Fiber.new {
      while true
        @connection.handle

        Fiber.yield
      end
    }

    @writing = Fiber.new {
      while true
        @connection.write

        Fiber.yield
      end
    }

    @defaults = [@listening, @writing, @reading, @handling]
    
    self.loop
  end

  def stop
    if !@started
      return
    end

    @started  = false
    @stopping = true

    @event.finalize
    @connection.finalize

    @stopping = false
  end

  def loop
    while true
      @defaults.each {|fiber|
        begin
          fiber.resume
        rescue FiberError
          DNS.debug 'Something went deeply wrong in the dispatcher, aborting.'
          Process::exit 23
        rescue Exception => e
          DNS.debug e
        end
      }

      @intervals.each {|fiber, meta|
        begin
          if !@intervals[fiber]
            raise FiberError
          end

          if meta[:at] <= Time.now
            fiber.resume

            meta[:at] += meta[:offset]
          end
        rescue FiberError
          clearInterval meta
        rescue Exception => e
          DNS.debug e
        end
      }

      @timeouts.each {|fiber, meta|
        begin
          if !@timeouts[fiber]
            raise FiberError
          end

          if meta[:at] <= Time.now
            fiber.resume

            clearTimeout meta
          end
        rescue FiberError
          clearTimeout meta
        rescue Exception => e
          DNS.debug e
        end
      }
    end
  end

  def setTimeout (fiber, time)
    @timeouts[fiber] = {
      :fiber => fiber,
      :at  => Time.now + time,
      :on  => Time.now,
    }
  end

  def clearTimeout (timeout)
    @timeouts.delete(timeout[:fiber])
  end

  def setInterval (fiber, time)
    @intervals[fiber] = {
      :fiber  => fiber,
      :offset => time,
      :at   => Time.now + time,
      :on   => Time.now,
    }
  end

  def clearInterval (interval)
    @intervals.delete(interval[:fiber])
  end

  def connections
    @connection.connections
  end

  def input
    @connection.input
  end

  def output
    @connection.output
  end

  def disconnecting
    @connection.disconnecting
  end

  def alias (*args)
    @event.alias(*args)
  end

  def register (*args)
    @event.register(*args)
  end

  def dispatch (*args)
    @event.dispatch(*args)
  end

  def execute (*args)
    @event.execute(*args)
  end

  # s = UDPSocket.new
  # s.bind(host, port)
  # s.recvfrom_nonblock(512)
end

end

end
