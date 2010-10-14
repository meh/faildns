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
#+

module DNS

#--
# The header contains the following fields:
# 
#                                     1  1  1  1  1  1
#       0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     |                      ID                       |
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     |QR|   Opcode  |AA|TC|RD|RA|   Z    |   RCODE   |
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     |                    QDCOUNT                    |
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     |                    ANCOUNT                    |
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     |                    NSCOUNT                    |
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     |                    ARCOUNT                    |
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
# 
# where:
# 
# ID              A 16 bit identifier assigned by the program that
#                 generates any kind of query.  This identifier is copied
#                 the corresponding reply and can be used by the requester
#                 to match up replies to outstanding queries.
# 
# QR              A one bit field that specifies whether this message is a
#                 query (0), or a response (1).
# 
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
# 
# AA              Authoritative Answer - this bit is valid in responses,
#                 and specifies that the responding name server is an
#                 authority for the domain name in question section.
# 
#                 Note that the contents of the answer section may have
#                 multiple owner names because of aliases.  The AA bit
#                 corresponds to the name which matches the query name, or
#                 the first owner name in the answer section.
# 
# TC              TrunCation - specifies that this message was truncated
#                 due to length greater than that permitted on the
#                 transmission channel.
# 
# RD              Recursion Desired - this bit may be set in a query and
#                 is copied into the response.  If RD is set, it directs
#                 the name server to pursue the query recursively.
#                 Recursive query support is optional.
# 
# RA              Recursion Available - this be is set or cleared in a
#                 response, and denotes whether recursive query support is
#                 available in the name server.
# 
# Z               Reserved for future use.  Must be zero in all queries
#                 and responses.
# 
# RCODE           Response code - this 4 bit field is set as part of
#                 responses.  The values have the following
#                 interpretation:
# 
#                 0               No error condition
# 
#                 1               Format error - The name server was
#                                 unable to interpret the query.
# 
#                 2               Server failure - The name server was
#                                 unable to process this query due to a
#                                 problem with the name server.
# 
#                 3               Name Error - Meaningful only for
#                                 responses from an authoritative name
#                                 server, this code signifies that the
#                                 domain name referenced in the query does
#                                 not exist.
# 
#                 4               Not Implemented - The name server does
#                                 not support the requested kind of query.
# 
#                 5               Refused - The name server refuses to
#                                 perform the specified operation for
#                                 policy reasons.  For example, a name
#                                 server may not wish to provide the
#                                 information to the particular requester,
#                                 or a name server may not wish to perform
#                                 a particular operation (e.g., zone
#                                 transfer) for particular data.
# 
#                 6-15            Reserved for future use.
# 
# QDCOUNT         an unsigned 16 bit integer specifying the number of
#                 entries in the question section.
# 
# ANCOUNT         an unsigned 16 bit integer specifying the number of
#                 resource records in the answer section.
# 
# NSCOUNT         an unsigned 16 bit integer specifying the number of name
#                 server resource records in the authority records
#                 section.
# 
# ARCOUNT         an unsigned 16 bit integer specifying the number of
#                 resource records in the additional records section.
#++

# "C\x9F\x01\x00\x00\x01\x00\x00\x00\x00\x00\x00\x03lol\x03com\x00\x00\x01\x00\x01"

class Header
  def self.parse (string)
    data = string.unpack('nnnnnn')

    result = {}

    result[:ID] = data[0]

    result[:QR]     = (data[1] & 0x8000 != 0) ? :RESPONSE : :QUERY
    result[:OPCODE] = { 0 => :QUERY, 1 => :IQUERY, 2 => :STATUS }[((data[1] & 0x7800) >> 11)]
    result[:AA]     = (data[1] & 0x400 != 0)
    result[:TC]     = (data[1] & 0x200 != 0)
    result[:RD]     = (data[1] & 0x100 != 0)
    result[:RA]     = (data[1] & 0x80  != 0)
    result[:Z]      = (data[1] & 0x70  == 0)
    result[:RCODE]  = (data[1] & 0xf)

    result[:QDCOUNT] = data[2]
    result[:ANCOUNT] = data[3]
    result[:NSCOUNT] = data[4]
    result[:ARCOUNT] = data[5]

    return result
  end

  def self.length
    12
  end

  def initialize (what)
    if what.is_a? String
      self.from_hash(Header.parse(what))
    elsif what.is_a? Hash
      self.from_hash(what)
    else
      raise ArgumentError.new('You have to pass a String or a Hash.')
    end
  end
end

end
