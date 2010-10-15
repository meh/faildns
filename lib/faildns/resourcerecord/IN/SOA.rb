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
#     /                     MNAME                     /
#     /                                               /
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     /                     RNAME                     /
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     |                    SERIAL                     |
#     |                                               |
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     |                    REFRESH                    |
#     |                                               |
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     |                     RETRY                     |
#     |                                               |
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     |                    EXPIRE                     |
#     |                                               |
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     |                    MINIMUM                    |
#     |                                               |
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
# 
# where:
# 
# MNAME           The <domain-name> of the name server that was the
#                 original or primary source of data for this zone.
# 
# RNAME           A <domain-name> which specifies the mailbox of the
#                 person responsible for this zone.
# 
# SERIAL          The unsigned 32 bit version number of the original copy
#                 of the zone.  Zone transfers preserve this value.  This
#                 value wraps and should be compared using sequence space
#                 arithmetic.
# 
# REFRESH         A 32 bit time interval before the zone should be
#                 refreshed.
# 
# RETRY           A 32 bit time interval that should elapse before a
#                 failed refresh should be retried.
# 
# EXPIRE          A 32 bit time value that specifies the upper limit on
#                 the time interval that can elapse before the zone is no
#                 longer authoritative.
# 
# MINIMUM         The unsigned 32 bit minimum TTL field that should be
#                 exported with any RR from this zone.
# 
# SOA records cause no additional section processing.
# 
# All times are in units of seconds.
# 
# Most of these fields are pertinent only for name server maintenance
# operations.  However, MINIMUM is used in all query operations that
# retrieve RRs from a zone.  Whenever a RR is sent in a response to a
# query, the TTL field is set to the maximum of the TTL field from the RR
# and the MINIMUM field in the appropriate SOA.  Thus MINIMUM is a lower
# bound on the TTL field for all RRs in a zone.  Note that this use of
# MINIMUM should occur when the RRs are copied into the response and not
# when the zone is loaded from a master file or via a zone transfer.  The
# reason for this provison is to allow future dynamic update facilities to
# change the SOA RR with known semantics.
#++

class SOA < Data
  def self._parse (string, original)
    result = {}

    result[:MNAME] = DomainName.parse(string, original)
    result[:RNAME] = DomainName.parse(string, original)

    result[:SERIAL]  = string.unpack('N'); string[0, 4] = ''
    result[:REFRESH] = string.unpack('N'); string[0, 4] = ''
    result[:RETRY]   = string.unpack('N'); string[0, 4] = ''
    result[:EXPIRE]  = string.unpack('N'); string[0, 4] = ''
    result[:MINIMUM] = string.unpack('N'); string[0, 4] = ''

    SOA.new(result)
  end

  def initialize (data)
    @data = data
  end

  def [] (name)
    @data[name]
  end

  def pack
    result[:MNAME].pack + result[:RNAME].pack + [result[:SERIAL]].pack('N') +
    [result[:REFRESH]].pack('N') + [result[:RETRY]].pack('N')  + [result[:EXPIRE]].pack('N')  +
    [result[:MINIMUM]].pack('N')
  end
end

end

end

end
