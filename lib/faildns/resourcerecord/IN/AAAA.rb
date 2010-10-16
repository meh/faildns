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
require 'faildns/ip'

module DNS

class ResourceRecord

module IN

#--
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     |                    ADDRESS                    |
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
# 
# where:
# 
# ADDRESS         A 128 bit Internet address.
# 
# Hosts that have multiple Internet addresses will have multiple AAAA
# records.
# 
# AAAA records cause no additional section processing.  The RDATA section of
# an AAAA line in a master file is an Internet address expressed as a name in 
# the IP6.ARPA domain by a sequence of nibbles separated by dots with the suffix
# ".IP6.ARPA". The sequence of nibbles is encoded in reverse order, i.e., the
# low-order nibble is encoded first, followed by the next low-order
# nibble and so on.  Each nibble is represented by a hexadecimal digit.
#++

class AAAA < Data
  def self._parse (string, original)
    AAAA.new(IP.parse(string))
  end

  def self.length
    16
  end

  attr_reader :ip

  def initialize (what)
    @ip = IP.new(what)
  end

  def pack
    @ip.pack
  end

  def to_s
    @ip.to_s
  end
end

end

end

end
