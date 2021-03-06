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
#++

class Status
	Values = {
		0  => :NOERROR,
		1  => :FORMERR,
		2  => :SERVFAIL,
		3  => :NXDOMAIN,
		4  => :NOTIMP,
		5  => :REFUSED,
		6  => :YXDOMAIN,
		7  => :YXRRSET,
		8  => :NXRRSET,
		9  => :NOTAUTH,
		10 => :NOTZONE,
		11 => :RESERVED11,
		12 => :RESERVED12,
		13 => :RESERVED13,
		14 => :RESERVED14,
		15 => :RESERVED15,
		16 => :BADSIG,
		17 => :BADKEY,
		18 => :BADTIME,
		19 => :BADMODE,
		20 => :BADNAME,
		21 => :BADALG,
		22 => :BADTRUNC
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

	hash_on :@internal

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
