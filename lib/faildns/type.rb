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

#--
# TYPE fields are used in resource records.  Note that these types are a
# subset of QTYPEs.
# 
# TYPE            value and meaning
# 
# A               1 a host address
# 
# NS              2 an authoritative name server
# 
# MD              3 a mail destination (Obsolete - use MX)
# 
# MF              4 a mail forwarder (Obsolete - use MX)
# 
# CNAME           5 the canonical name for an alias
# 
# SOA             6 marks the start of a zone of authority
# 
# MB              7 a mailbox domain name (EXPERIMENTAL)
# 
# MG              8 a mail group member (EXPERIMENTAL)
# 
# MR              9 a mail rename domain name (EXPERIMENTAL)
# 
# NULL            10 a null RR (EXPERIMENTAL)
# 
# WKS             11 a well known service description
# 
# PTR             12 a domain name pointer
# 
# HINFO           13 host information
# 
# MINFO           14 mailbox or mail list information
# 
# MX              15 mail exchange
# 
# TXT             16 text strings
#++

class Type
  Values = {
    1  => :A,
    2  => :NS,
    3  => :MD,
    4  => :MF,
    5  => :CNAME,
    6  => :SOA,
    7  => :MB,
    8  => :MG,
    9  => :MR,
    10 => :NULL,
    11 => :WKS,
    12 => :PTR,
    13 => :HINFO,
    14 => :MINFO,
    15 => :MX,
    16 => :TXT
  }

  def self.parse (string)
    result = Type.new(string.unpack('n').first)
    string[0, Type.length] = ''

    return result
  end

  def self.length (string=nil)
    2
  end

  attr_reader :value

  def initialize (value)
    if value.is_a? Symbol
      @value = Values.find {|key, val| val == value}.first rescue nil
    else
      @value = value
    end

    if !self.to_sym
      raise ArgumentError.new('The passed value is not a suitable type.')
    end
  end

  def pack
    [@value].pack('n')
  end

  def to_sym
    Values[@value]
  end

  def to_s
    Values[@value].to_s
  end
end

end
