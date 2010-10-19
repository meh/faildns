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

require 'faildns/resourcerecord/IN'

module DNS

#--
# The answer, authority, and additional sections all share the same
# format: a variable number of resource records, where the number of
# records is specified in the corresponding count field in the header.
# Each resource record has the following format:
#                                     1  1  1  1  1  1
#       0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     |                                               |
#     /                                               /
#     /                      NAME                     /
#     |                                               |
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     |                      TYPE                     |
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     |                     CLASS                     |
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     |                      TTL                      |
#     |                                               |
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     |                   RDLENGTH                    |
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--|
#     /                     RDATA                     /
#     /                                               /
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
# 
# where:
# 
# NAME            a domain name to which this resource record pertains.
# 
# TYPE            two octets containing one of the RR type codes.  This
#                 field specifies the meaning of the data in the RDATA
#                 field.
# 
# CLASS           two octets which specify the class of the data in the
#                 RDATA field.
# 
# TTL             a 32 bit unsigned integer that specifies the time
#                 interval (in seconds) that the resource record may be
#                 cached before it should be discarded.  Zero values are
#                 interpreted to mean that the RR can only be used for the
#                 transaction in progress, and should not be cached.
# 
# RDLENGTH        an unsigned 16 bit integer that specifies the length in
#                 octets of the RDATA field.
# 
# RDATA           a variable length string of octets that describes the
#                 resource.  The format of this information varies
#                 according to the TYPE and CLASS of the resource record.
#                 For example, the if the TYPE is A and the CLASS is IN,
#                 the RDATA field is a 4 octet ARPA Internet address.
#++ 

class ResourceRecord
  def self.parse (string, original)
    string.force_encoding 'BINARY'

    ResourceRecord.new {|r|
      r.name  = DomainName.parse(string, original)
      r.type  = Type.parse(string)
      r.class = Class.parse(string)

      r.ttl = string.unpack('N').first; string[0, 4] = ''

      r.length = string.unpack('n').first; string[0, 2] = ''
      r.data   = ResourceRecord.const_get(r.class.to_sym).const_get(r.type.to_sym) rescue nil

      if !r.data
        r.data = ResourceRecord.const_get(r.class.to_sym).const_get(:NULL)
        DNS.debug "ResourceRecord::#{r.class}::#{r.type} not found."
      end
      
      r.data = r.data.parse(string, r.length, original)
    }
  end

  def self.length (string)
    string.force_encoding 'BINARY'

    (tmp = DomainName.length(string) + Type.length + Class.length + 4) + string[tmp, 2].unpack('n').first + 2
  end

  def initialize (what={})
    if !what.is_a? Hash
      raise ArgumentError.new('You have to pass a Hash.')
    end

    @data = what

    if block_given?
      yield self
    end
  end

  def name;   @data[:NAME]     end
  def type;   @data[:TYPE]     end
  def class;  @data[:CLASS]    end
  def ttl;    @data[:TTL]      end
  def length; @data[:RDLENGTH] end
  def data;   @data[:RDATA]    end

  def name= (val);   @data[:NAME]     = DomainName.new(val) end
  def type= (val);   @data[:TYPE]     = Type.new(val)       end
  def class= (val);  @data[:CLASS]    = Class.new(val)      end
  def ttl= (val);    @data[:TTL]      = val                 end
  def length= (val); @data[:RDLENGTH] = val                 end
  def data= (val);   @data[:RDATA]    = val                 end

  def pack
    self.name.pack + self.type.pack + self.class.pack + [self.ttl].pack('N') +
    [self.length].pack('n') + self.data.pack
  end

  def inspect
    "#<ResourceRecord:(#{self.name} #{self.class} #{self.type} [#{self.ttl}]) #{self.data.inspect}>"
  end
end

end
