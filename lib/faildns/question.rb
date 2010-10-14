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

require 'faildns/qtype'
require 'faildns/qclass'

module DNS

#--
# The question section is used to carry the "question" in most queries,
# i.e., the parameters that define what is being asked.  The section
# contains QDCOUNT (usually 1) entries, each of the following format:
# 
#                                     1  1  1  1  1  1
#       0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     |                                               |
#     /                     QNAME                     /
#     /                                               /
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     |                     QTYPE                     |
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     |                     QCLASS                    |
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
# 
# where:
# 
# QNAME           a domain name represented as a sequence of labels, where
#                 each label consists of a length octet followed by that
#                 number of octets.  The domain name terminates with the
#                 zero length octet for the null label of the root.  Note
#                 that this field may be an odd number of octets; no
#                 padding is used.
# 
# QTYPE           a two octet code which specifies the type of the query.
#                 The values for this field include all codes valid for a
#                 TYPE field, together with some more general codes which
#                 can match more than one type of RR.
# 
# QCLASS          a two octet code that specifies the class of the query.
#                 For example, the QCLASS field is IN for the Internet.
#++

class Question
  def self.parse (string)
    string = string.clone
    result = {}

    # Each label is composed of a byte for length (max 67 octects) and the
    # length bytes, so I get the bytes and then cut out the length + 1 bytes
    # so we have the next label.
    #
    # When the zero label is found it knows that it's finished.
    result[:QNAME] = []
    while (length = string.unpack('c').first) != 0 && length <= 67
      result[:QNAME] << string[1, length]
      string[0, length + 1] = ''
    end

    string[0, 1] = ''

    result[:QTYPE]  = QType.new(string.unpack('n').first)
    result[:QCLASS] = QClass.new(string.unpack('xxn').first)

    return result
  end

  def self.length (string)
    string = string.clone
    result = 0

    while (length = string.unpack('c').first) != 0 && length <= 67
      result                += 1 + length
      string[0, length + 1]  = ''
    end

    result += 1 + 2 + 2

    return result
  end

  def initialize (what)
    if what.is_a? String
      @data = Question.parse(what)
    elsif what.is_a? Hash
      @data = what
    else
      raise ArgumentError.new('You have to pass a String or a Hash.')
    end
  end

  def [] (name)
    @data[name]
  end

  def pack
    result = ''

    self[:QNAME].each {|name|
      result += [name.length].pack('c') + name
    }

    result += [0].pack('c')

    result += self[:QTYPE].pack
    result += self[:QCLASS].pack

    return result
  end
end

end
