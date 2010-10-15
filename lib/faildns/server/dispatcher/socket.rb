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
    @dispatcher = dispatcher

    if what.is_a? TCPSocket
      @type = :TCP
      @ip   = what.peeraddr[3]
      @port = what.addr[1]

      @socket = what
    else
      @type = :UDP
      @ip   = what[3]
      @port = what[1]

      @socket = UDPSocket.new
      @socket.connect(@ip, @port)
    end
  end

  def send (message)
    @dispatcher.connection.send message, self
  end

  def raw (data)
    if @socket.is_a? TCPSocket
      @socket.send_nonblock(data)
    else
      @socket.send(data, 0)
    end
  end

  def close
    if @socket.is_a? TCPSocket
      @socket.close
    end
  end
end

end

end

end

end
