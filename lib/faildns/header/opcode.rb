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

class Header

#--
# OPCODE          A four bit field that specifies kind of query in this
#                 message.  This value is set by the originator of a query
#                 and copied into the response.  The values are:
# 
#                 0               a standard query (QUERY)
# 
#                 1               an inverse query (IQUERY)
# 
#                 2               a server status request (STATUS)
# 
#                 3-15            reserved for future use
#++

class Opcode
  Values = {
    0  => :QUERY,
    1  => :IQUERY,
    2  => :STATUS,
    3  => :RESERVED3,
    4  => :NOTIFY,
    5  => :UPDATE,
    6  => :RESERVED6,
    7  => :RESERVED7,
    8  => :RESERVED8,
    9  => :RESERVED9,
    10 => :RESERVED10,
    11 => :RESERVED11,
    12 => :RESERVED12,
    13 => :RESERVED13,
    14 => :RESERVED14,
    15 => :RESERVED15
  }

  attr_reader :value

  def initialize (value)
    if value.is_a? Symbol
      @value = Values.find {|key, val| val == value}.first rescue nil
    elsif value.is_a? Integer
      @value = value
    else
      @value = value.value rescue nil
    end

    if !self.to_sym
      raise ArgumentError.new('The passed value is not a suitable type.')
    end
  end

  def == (what)
    if what.is_a? Symbol
      self.to_sym == what
    elsif value.is_a? Integer
      @value == what
    else
      @value == what.value rescue false
    end
  end

  def to_sym
    Values[@value]
  end

  def to_s
    Values[@value].to_s
  end
end

end

end
