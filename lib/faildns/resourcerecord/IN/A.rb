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
#     |                    ADDRESS                    |
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
# 
# where:
# 
# ADDRESS         A 32 bit Internet address.
# 
# Hosts that have multiple Internet addresses will have multiple A
# records.
# 
# A records cause no additional section processing.  The RDATA section of
# an A line in a master file is an Internet address expressed as four
# decimal numbers separated by dots without any imbedded spaces (e.g.,
# "10.2.0.52" or "192.0.5.6").
#++

class A < Data
  def initialize (string, original)
    @raw = string
  end

  def pack
    @raw
  end

  def to_s
    @raw.unpack('CCCC').join('.')
  end
end

end

end

end
