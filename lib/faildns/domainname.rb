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
# Domain names in messages are expressed in terms of a sequence of labels.
# Each label is represented as a one octet length field followed by that
# number of octets.  Since every domain name ends with the null label of
# the root, a domain name is terminated by a length byte of zero.  The
# high order two bits of every length octet must be zero, and the
# remaining six bits of the length field limit the label to 63 octets or
# less.
#
# To simplify implementations, the total length of a domain name (i.e.,
# label octets and label length octets) is restricted to 255 octets or
# less.
#
# Although labels can contain any 8 bit values in octets that make up a
# label, it is strongly recommended that labels follow the preferred
# syntax described elsewhere in this memo, which is compatible with
# existing host naming conventions.  Name servers and resolvers must
# compare labels in a case-insensitive manner (i.e., A=a), assuming ASCII
# with zero parity.  Non-alphabetic codes must match exactly.
#
# In order to reduce the size of messages, the domain system utilizes a
# compression scheme which eliminates the repetition of domain names in a
# message.  In this scheme, an entire domain name or a list of labels at
# the end of a domain name is replaced with a pointer to a prior occurance
# of the same name.
#
# The pointer takes the form of a two octet sequence:
#
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     | 1  1|                OFFSET                   |
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#
# The first two bits are ones.  This allows a pointer to be distinguished
# from a label, since the label must begin with two zero bits because
# labels are restricted to 63 octets or less.  (The 10 and 01 combinations
# are reserved for future use.)  The OFFSET field specifies an offset from
# the start of the message (i.e., the first octet of the ID field in the
# domain header).  A zero offset specifies the first byte of the ID field,
# etc.
#
# The compression scheme allows a domain name in a message to be
# represented as either:
#
#    - a sequence of labels ending in a zero octet
#
#    - a pointer
#
#    - a sequence of labels ending with a pointer
#
# Pointers can only be used for occurances of a domain name where the
# format is not class specific.  If this were not the case, a name server
# or resolver would be required to know the format of all RRs it handled.
# As yet, there are no such cases, but they may occur in future RDATA
# formats.
#
# If a domain name is contained in a part of the message subject to a
# length field (such as the RDATA section of an RR), and compression is
# used, the length of the compressed name is used in the length
# calculation, rather than the length of the expanded name.
#
# Programs are free to avoid using pointers in messages they generate,
# although this will reduce datagram capacity, and may cause truncation.
# However all programs are required to understand arriving messages that
# contain pointers.
#
# For example, a datagram might need to use the domain names F.ISI.ARPA,
# FOO.F.ISI.ARPA, ARPA, and the root.  Ignoring the other fields of the
# message, these domain names might be represented as:
#
#        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     20 |           1           |           F           |
#        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     22 |           3           |           I           |
#        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     24 |           S           |           I           |
#        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     26 |           4           |           A           |
#        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     28 |           R           |           P           |
#        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     30 |           A           |           0           |
#        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#
#        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     40 |           3           |           F           |
#        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     42 |           O           |           O           |
#        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     44 | 1  1|                20                       |
#        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#
#        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     64 | 1  1|                26                       |
#        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#
#        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     92 |           0           |                       |
#        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#
# The domain name for F.ISI.ARPA is shown at offset 20.  The domain name
# FOO.F.ISI.ARPA is shown at offset 40; this definition uses a pointer to
# concatenate a label for FOO to the previously defined F.ISI.ARPA.  The
# domain name ARPA is defined at offset 64 using a pointer to the ARPA
# component of the name F.ISI.ARPA at 20; note that this pointer relies on
# ARPA being the last label in the string at 20.  The root domain name is
# defined by a single octet of zeros at 92; the root domain name has no
# labels.
#++

require 'unicode_utils'
require 'simpleidn'

class DomainName
	def self.pointer (string, offset)
		string[offset.unpack('n').first & 0x3FFF, 512]
	end

	def self.unpack (string, whole)
		result = ''

		while (length = string.unpack('c').first) != 0 && (length & 0xC0) != 0xC0
			unless result.empty?
				result << '.'
			end

			result << string[1, length]
			string[0, length + 1]  = ''
		end

		if length & 0xC0 == 0xC0
			result << '.' unless result.empty?
			result << DomainName.unpack(DomainName.pointer(whole, string), whole)

			string[0, 2] = ''
		else
			string[0, 1] = ''
		end

		DomainName.new result
	end

	def self.length (string)
		string = string.dup
		result = 0

		if string.unpack('c').first & 0xC0 == 0xC0
			result = 2
		else
			while (length = string.unpack('c').first) != 0 && (length & 0xC0) == 0
				result                += 1 + length
				string[0, length + 1]  = ''
			end

			if length & 0xC0 == 0xC0
				result += 2
			else
				result += 1
			end
		end

		result
	end

	include DNS::Comparable

	def initialize (domain = nil)
		replace domain if domain
	end

	def replace (domain)
		if domain.nil? || domain.to_s.empty?
			@internal = nil

			return
		end

		internal = UnicodeUtils.downcase(SimpleIDN.to_unicode(domain.to_s))
		pieces   = SimpleIDN.to_ascii(internal).split('.')

		if pieces.empty? || pieces.any? { |p| p.length > 63 || p.empty? }
			raise ArgumentError, "#{domain} is an invalid domain (either longer than 63 part or empty part)"
		end

		@internal = internal
	end

	alias update replace

	hash_on :@internal

	def nil?
		@internal.nil?
	end

	def to_s
		@internal
	end

	alias to_str to_s

	def to_ascii
		SimpleIDN.to_ascii(@internal)
	end

	def pack (message = nil, offset = nil)
		result = ''

		if message && offset && message.compress?
			unique, pointer = message.pointer_for(to_ascii, offset)

			unique.each {|part|
				result << [part.length].pack('c') + part
			}

			result << if pointer
				[0xC000 | pointer].pack('n')
			else
				[0].pack('c')
			end
		else
			to_ascii.split('.').each {|part|
				result << [part.length].pack('c') + part
			}

			result << [0].pack('c')
		end

		result
	end
end

end
