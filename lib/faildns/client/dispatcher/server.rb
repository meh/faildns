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

require 'timeout'
require 'socket'

require 'faildns/client/dispatcher/response'

module DNS

class Client

class Dispatcher

class Server
  attr_reader :host, :port

  def initialize (host, port=53)
    @host = host
    @port = port

    @socket = UDPSocket.new
    @socket.connect(@host, @port)

    @responses = {}
  end

  def to_s
    @host
  end

  def send (message)
    DNS.debug "[Client > #{self.inspect}] #{message.inspect}", { :level => 9, :separator => "\n" }

    @socket.print message.pack
  end

  def recv (id, timeout=10)
    if id.is_a? Message
      id = id.header.id
    elsif id.is_a? Header
      id = id.id
    end

    if !@responses.has_key? id
      _recv(timeout, id)
    end

    response = @responses.delete(id)

    DNS.debug "[Client < #{self.inspect}] #{response.message.inspect rescue nil}", { :level => 9, :separator => "\n" }

    return response
  end

  def to_s
    "#{@host}#{":#{@port}" if port != 53}"
  end

  private

  def _recv (timeout, id=nil)
    Timeout.timeout(timeout) {
      while (msg = @socket.recvfrom(512))
        message = Message.parse(msg[0])

        @responses[message.header.id] = Response.new(self, message)

        if id == message.header.id
          break
        end
      end
    }
  end
end

end

end

end
