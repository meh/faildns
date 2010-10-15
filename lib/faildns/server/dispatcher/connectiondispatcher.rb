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
require 'socket'

require 'faildns/server/dispatcher/socket'
require 'faildns/message'

module DNS

class Server

class Dispatcher

class ConnectionDispatcher
  attr_reader :server, :dispatcher, :listening

  def initialize (dispatcher)
    @server     = dispatcher.server
    @dispatcher = dispatcher

    @input  = []
    @output = []

    @host = @server.options[:host] || '0.0.0.0'
    @port = @server.options[:port] || 53

    @sockets = []
  end

  def start
    @listening = {
      :TCP => TCPServer.new(@host, @port),
      :UDP => UDPSocket.new
    }

    @listening[:UDP].bind(@host, @port)
  end

  def send (message, socket)
    @output.push([message, socket])
  end

  def accept (timeout=0)
    begin
      if IO::select [@listening[:TCP]], nil, nil, timeout
        @sockets.push @listening[:TCP].accept.nonblock
      end
    rescue Errno::EAGAIN
    rescue Exception => e
    end
  end

  def read (timeout=0.1)
    reading, = IO::select @sockets, nil, nil, timeout

    (reading || []).each {|socket|
      @input.push [socket.recv_nonblock(65535), socket]
      @sockets.delete(socket)
    }

    begin
      @input.push @listening[:UDP].recvfrom_nonblock(512)
    rescue Errno::EAGAIN
    end
  end

  def handle
    while input = @input.shift
      Thread.new(input) {|input|
        begin
          @dispatcher.dispatch :input, Socket.new(@dispatcher, input[1]), Message.new(input[0])
        rescue Exception => e
          DNS.debug e
        end
      }
    end
  end

  def write (timeout=0)
    tmp = []

    while (output = @output.shift)
      begin
        output[1].raw(output[0].pack)
        output[1].close
      rescue Errno::EAGAIN
        tmp.push(output)
      rescue Exception => e
        DNS.debug e
      end
    end

    @output.insert(-1, *tmp)
  end
end

end

end

end
