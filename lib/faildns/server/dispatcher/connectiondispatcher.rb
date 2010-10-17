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

  def read
    reading, = IO::select @sockets.concat([@listening[:UDP], @listening[:TCP]])

    if !reading
      return
    end

    reading.each {|socket|
      if socket.is_a? TCPServer
        @sockets.push @listening[:TCP].accept_nonblock
      elsif socket.is_a? TCPSocket
        self.handle socket.recv_nonblock(65535), socket
        @sockets.delete(socket)
      else
        begin
          self.handle *@listening[:UDP].recvfrom_nonblock(512)
        rescue Errno::EAGAIN
        end
      end
    }
  end

  def handle (string, socket)
    Thread.new(@dispatcher, string, socket) {|dispatcher, string, socket|
      begin
        socket  = Socket.new(dispatcher, socket)
        message = Message.parse(string)

        DNS.debug "[Server < #{socket.inspect}] #{message.inspect}", { :level => 9 }

        @dispatcher.dispatch :input, socket, message
      rescue Exception => e
        DNS.debug e
      end
    }
  end
end

end

end

end
