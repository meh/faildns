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
require 'faildns/message'

module DNS

class Client
  attr_reader :options, :servers

  def initialize (options={})
    @options = options

    @servers = @options[:servers] || []

    if block_given?
      yield self
    end
  end

  def resolve (domain, timeout=10, tries=3)
    result = nil
    socket = UDPSocket.new

    id = (rand * 100000).to_i % 65536

    1.upto(tries) {
      @servers.each {|server|
        socket.connect(server.to_s, 53)
  
        socket.print Message.new(
          Header.new {|h|
            h.id = id
  
            h.type  = :QUERY
            h.class = :QUERY
  
            h.recursive!
  
            h.questions = 1
          },
  
          [Question.new {|q|
            q.name = domain
  
            q.class = :IN
            q.type  = :A
          }]
        ).pack

        if (tmp = Timeout.timeout(timeout) { socket.recvfrom(512) } rescue nil)
          DNS.debug tmp, { :level => 9 }

          tmp = Message.parse(tmp[0])

          if tmp.header.status == :NXDOMAIN
            result = false
            break
          end

          if tmp.header.status == :NOERROR && tmp.header.id == id
            result = tmp.answers.find {|answer| answer.type == :A}.data.to_s rescue nil
            break
          end
        end
      }

      if !result.nil?
        break
      end
    }

    return result
  end

  def query (message, timeout=10)
    result = []
    socket = UDPSocket.new

    @servers.each {|server|
      socket.connect(server.to_s, 53)

      socket.print message.pack

      if (tmp = Timeout.timeout(timeout) { socket.recvfrom(512) } rescue nil)
        DNS.debug tmp, { :level => 9 }

        result.push Message.parse(tmp[0])
      end
    }

    return result
  end
end

end
