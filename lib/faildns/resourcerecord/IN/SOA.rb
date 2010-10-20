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

    [:SERIAL, :REFRESH, :RETRY, :EXPIRE, :MINIMUM].each {|value|
      result[value] = string.unpack('N').first; string[0, 4] = ''
    }

    SOA.new(result)
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

  def server;      @data[:MNAME]   end
  def responsible; @data[:RNAME]   end
  def serial;      @data[:SERIAL]  end
  def refresh;     @data[:REFRESH] end
  def retry;       @data[:RETRY]   end
  def expire;      @data[:EXPIRE]  end
  def minimum;     @data[:MINIMUM] end

  def server= (val);      @data[:MNAME]   = DomainName.new(val) end
  def responsible= (val); @data[:RNAME]   = DomainName.new(val) end
  def serial= (val);      @data[:SERIAL]  = val.to_i            end
  def refresh= (val);     @data[:REFRESH] = val.to_i            end
  def retry= (val);       @data[:RETRY]   = val.to_i            end
  def expire= (val);      @data[:EXPIRE]  = val.to_i            end
  def minimum= (val);     @data[:MINIMUM] = val.to_i            end

  def pack
    self.server.pack + self.responsible.pack + [self.serial].pack('N') + [self.refresh].pack('N')+
    [self.retry].pack('N') + [self.expire].pack('N') + [self.minimum].pack('N')
  end

  def length
    self.pack.length
  end

  def inspect
    "#<IN SOA: #{self.server}#{" (#{self.responsible})" if !self.responsible.to_s.empty?} serial=#{self.serial} refresh=#{self.refresh} retry=#{self.retry} expire=#{self.expire} minimum=#{self.minimum}>"
  end
end

end

end

end
