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

require 'ipaddr'

module DNS

class IP
  attr_reader :version

  def initialize (what)
    if (what.is_a?(String) && what.length <= 6) || what.is_a?(Integer)
      @value = IPAddr.new_ntoh(what)
    elsif what.is_a?(String) || what.is_a?(IP) || what.is_a?(IPAddr)
      @value = IPAddr.new(what.to_s)
    else
      DNS.debug @value.inspect

      raise ArgumentError.new 'wat is dis i dont even'
    end

    @version = (@value.ipv4?) ? 4 : 6
  end

  def pack
    @value.hton
  end

  def to_s
    @value.to_s
  end

  alias to_str to_s
end

end
