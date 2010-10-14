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
# All RRs have the same top level format shown below:
# 
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
# 
# where:
# 
# NAME            an owner name, i.e., the name of the node to which this
#                 resource record pertains.
# 
# TYPE            two octets containing one of the RR TYPE codes.
# 
# CLASS           two octets containing one of the RR CLASS codes.
# 
# TTL             a 32 bit signed integer that specifies the time interval
#                 that the resource record may be cached before the source
#                 of the information should again be consulted.  Zero
#                 values are interpreted to mean that the RR can only be
#                 used for the transaction in progress, and should not be
#                 cached.  For example, SOA records are always distributed
#                 with a zero TTL to prohibit caching.  Zero values can
#                 also be used for extremely volatile data.
# 
# RDLENGTH        an unsigned 16 bit integer that specifies the length in
#                 octets of the RDATA field.
# 
# RDATA           a variable length string of octets that describes the
#                 resource.  The format of this information varies
#                 according to the TYPE and CLASS of the resource record.
#++ 

# labels = 1 byte (length) + length bytes (content)

class ResourceRecord

end

end
