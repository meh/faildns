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
#     |                  PREFERENCE                   |
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     /                   EXCHANGE                    /
#     /                                               /
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#
# where:
#
# PREFERENCE      A 16 bit integer which specifies the preference given to
#                 this RR among others at the same owner.  Lower values
#                 are preferred.
#
# EXCHANGE        A <domain-name> which specifies a host willing to act as
#                 a mail exchange for the owner name.
#
# MX records cause type A additional section processing for the host
# specified by EXCHANGE.  The use of MX RRs is explained in detail in
# [RFC-974].
#++

class MX < Data
	def self._unpack (string, original)
		MX.new(string.unpack('n'), DomainName.unpack(string[2, 255], original))
	end

	attr_reader :preference, :exchange

	def initialize (preference, exchange)
		@preference = preference
		@exchange   = exchange
	end

	hash_on :@preference, :@exchange

	def pack
		[@preference].pack('n') + @exchange.pack
	end

	def length
		pack.length
	end

	def to_s
		"#{@preference}) #{@exchange}"
	end
end

end

end

end
