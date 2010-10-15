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

require 'faildns/resourcerecord/data'

module DNS

class ResourceRecord

module IN

#--
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     /                  <anything>                   /
#     /                                               /
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
# 
# Anything at all may be in the RDATA field so long as it is 65535 octets
# or less.
# 
# NULL records cause no additional section processing.  NULL RRs are not
# allowed in master files.  NULLs are used as placeholders in some
# experimental extensions of the DNS.
#++

class NULL < Data
  def self._parse (string, original)
    NULL.new(string)
  end

  attr_reader :raw

  def initialize (raw)
    @raw = raw
  end

  def pack
    @raw
  end

  def to_s
    @raw
  end
end

end

end

end
