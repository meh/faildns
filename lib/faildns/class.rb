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
# CLASS fields appear in resource records.  The following CLASS mnemonics
# and values are defined:
#
# IN              1 the Internet
#
# CS              2 the CSNET class (Obsolete - used only for examples in
#                 some obsolete RFCs)
#
# CH              3 the CHAOS class
#
# HS              4 Hesiod [Dyer 87]
#++

class Class
	Values = {
		1 => :IN,
		2 => :CS,
		3 => :CH,
		4 => :HS
	}

	def self.unpack (string)
		result = new(string.unpack('n').first)

		string[0, length] = ''

		result
	end

	def self.length (string = nil)
		2
	end

	include DNS::Comparable

	def initialize (value)
		if value.is_a? Symbol
			@internal = Values.key(value)
		elsif value.is_a? Integer
			@internal = value
		else
			@internal = value.to_i
		end

		unless to_sym
			raise ArgumentError, 'the passed value is not a suitable class'
		end
	end

	hash_on :@internal

	def pack
		[to_i].pack('n')
	end

	def == (what)
		if what.is_a? Symbol
			to_sym == what
		elsif value.is_a? Integer
			@internal == what
		else
			@internal == what.to_i rescue false
		end
	end

	def to_sym
		Values[@internal]
	end

	def to_s
		to_sym.to_s
	end

	def to_i
		@internal
	end
end

end
