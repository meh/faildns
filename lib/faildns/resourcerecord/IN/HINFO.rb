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
#     /                      CPU                      /
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     /                       OS                      /
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#
# where:
#
# CPU             A <character-string> which specifies the CPU type.
#
# OS              A <character-string> which specifies the operating
#                 system type.
#
# Standard values for CPU and OS can be found in [RFC-1010].
#
# HINFO records are used to acquire general information about a host.  The
# main use is for protocols such as FTP that can use special procedures
# when talking between machines or operating systems of the same type.
#++

class HINFO < Data
	def self._unpack (string, original)
		string = string.clone

		cpu = string[1, (tmp = string.unpack('C'))]; string[0, tmp + 1] = ''
		os  = string[1, string.unpack('C')]

		HINFO.new(cpu, os)
	end

	attr_reader :cpu, :os

	def initialize (cpu, os)
		@cpu = cpu
		@os  = os
	end

	hash_on :@cpu, :@os

	def pack
		[@cpu.length].unpack('C') + @cpu + [@os.length].unpack('C') + @os
	end

	def length
		pack.length
	end

	def to_s
		"#{@os} on #{@cpu}"
	end
end

end

end

end
