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
#     /                   TXT-DATA                    /
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#
# where:
#
# TXT-DATA        One or more <character-string>s.
#
# TXT RRs are used to hold descriptive text.  The semantics of the text
# depends on the domain where it is found.
#++

class TXT < Data
	def self._unpack (string, original)
		data = []

		until string.empty?
			data.push(string[1, (tmp = string.unpack('C'))]); string[0, tmp + 1] = ''
		end

		TXT.new(data)
	end

	attr_reader :data

	def initialize (data)
		@data = data
	end

	hash_on :@data

	def pack
		data.map { |s| [s.length, s].pack('CA*') }.join
	end

	def length
		pack.length
	end
end

end

end

end
