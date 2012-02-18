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

class Header

#--
# QR              A one bit field that specifies whether this message is a
#                 query (0), or a response (1).
#++

class Type
	Values = {
		0 => :QUERY,
		1 => :RESPONSE
	}

	include DNS::Comparable

	def initialize (value)
		if value.is_a? Symbol
			@internal = Values.key(value)
		elsif value.is_a? Integer
			@internal = value
		else
			@internal = value.to_i rescue nil
		end

		unless to_sym
			raise ArgumentError, 'the passed value is not a suitable type.'
		end
	end

	hash_on :to_i

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

end
