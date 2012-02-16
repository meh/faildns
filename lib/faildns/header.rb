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

require 'faildns/header/type'
require 'faildns/header/opcode'
require 'faildns/header/status'

module DNS

#--
# The header contains the following fields:
#
#                                     1  1  1  1  1  1
#       0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     |                      ID                       |
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     |QR|   Opcode  |AA|TC|RD|RA|AD|CD|  |   RCODE   |
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     |                    QDCOUNT                    |
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     |                    ANCOUNT                    |
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     |                    NSCOUNT                    |
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     |                    ARCOUNT                    |
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#
# where:
#
# ID              A 16 bit identifier assigned by the program that
#                 generates any kind of query.  This identifier is copied
#                 the corresponding reply and can be used by the requester
#                 to match up replies to outstanding queries.
#
# QR              A one bit field that specifies whether this message is a
#                 query (0), or a response (1).
#
# OPCODE          A four bit field that specifies kind of query in this
#                 message.  This value is set by the originator of a query
#                 and copied into the response.  The values are:
#
#                 0               a standard query (QUERY)
#
#                 1               an inverse query (IQUERY)
#
#                 2               a server status request (STATUS)
#
#                 3-15            reserved for future use
#
# AA              Authoritative Answer - this bit is valid in responses,
#                 and specifies that the responding name server is an
#                 authority for the domain name in question section.
#
#                 Note that the contents of the answer section may have
#                 multiple owner names because of aliases.  The AA bit
#                 corresponds to the name which matches the query name, or
#                 the first owner name in the answer section.
#
# TC              TrunCation - specifies that this message was truncated
#                 due to length greater than that permitted on the
#                 transmission channel.
#
# RD              Recursion Desired - this bit may be set in a query and
#                 is copied into the response.  If RD is set, it directs
#                 the name server to pursue the query recursively.
#                 Recursive query support is optional.
#
# RA              Recursion Available - this be is set or cleared in a
#                 response, and denotes whether recursive query support is
#                 available in the name server.
#
# AD              The name server side of a security-aware recursive name server MUST
#                 NOT set the AD bit in a response unless the name server considers all
#                 RRsets in the Answer and Authority sections of the response to be
#                 authentic.  The name server side SHOULD set the AD bit if and only if
#                 the resolver side considers all RRsets in the Answer section and any
#                 relevant negative response RRs in the Authority section to be
#                 authentic.  The resolver side MUST follow the procedure described in
#                 Section 5 to determine whether the RRs in question are authentic.
#                 However, for backward compatibility, a recursive name server MAY set
#                 the AD bit when a response includes unsigned CNAME RRs if those CNAME
#                 RRs demonstrably could have been synthesized from an authentic DNAME
#                 RR that is also included in the response according to the synthesis
#                 rules described in [RFC2672].
#
# CD              The CD bit exists in order to allow a security-aware resolver to
#                 disable signature validation in a security-aware name server's
#                 processing of a particular query.
#
#                 The name server side MUST copy the setting of the CD bit from a query
#                 to the corresponding response.
#
#                 The name server side of a security-aware recursive name server MUST
#                 pass the state of the CD bit to the resolver side along with the rest
#                 of an initiating query, so that the resolver side will know whether
#                 it is required to verify the response data it returns to the name
#                 server side.  If the CD bit is set, it indicates that the originating
#                 resolver is willing to perform whatever authentication its local
#                 policy requires.  Thus, the resolver side of the recursive name
#                 server need not perform authentication on the RRsets in the response.
#                 When the CD bit is set, the recursive name server SHOULD, if
#                 possible, return the requested data to the originating resolver, even
#                 if the recursive name server's local authentication policy would
#                 reject the records in question.  That is, by setting the CD bit, the
#                 originating resolver has indicated that it takes responsibility for
#                 performing its own authentication, and the recursive name server
#                 should not interfere.
#
#                 If the resolver side implements a BAD cache (see Section 4.7) and the
#                 name server side receives a query that matches an entry in the
#                 resolver side's BAD cache, the name server side's response depends on
#                 the state of the CD bit in the original query.  If the CD bit is set,
#                 the name server side SHOULD return the data from the BAD cache; if
#                 the CD bit is not set, the name server side MUST return RCODE 2
#                 (server failure).
#
#                 The intent of the above rule is to provide the raw data to clients
#                 that are capable of performing their own signature verification
#                 checks while protecting clients that depend on the resolver side of a
#                 security-aware recursive name server to perform such checks.  Several
#                 of the possible reasons why signature validation might fail involve
#                 conditions that may not apply equally to the recursive name server
#                 and the client that invoked it.  For example, the recursive name
#                 server's clock may be set incorrectly, or the client may have
#                 knowledge of a relevant island of security that the recursive name
#                 server does not share.  In such cases, "protecting" a client that is
#                 capable of performing its own signature validation from ever seeing
#                 the "bad" data does not help the client.
#
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
#
# QDCOUNT         an unsigned 16 bit integer specifying the number of
#                 entries in the question section.
#
# ANCOUNT         an unsigned 16 bit integer specifying the number of
#                 resource records in the answer section.
#
# NSCOUNT         an unsigned 16 bit integer specifying the number of name
#                 server resource records in the authority records
#                 section.
#
# ARCOUNT         an unsigned 16 bit integer specifying the number of
#                 resource records in the additional records section.
#++

class Header
	Default = {
		AA: false, TC: false, RD: false, RA: false, AD: false, CD: true,

		QR:     Type.new(:QUERY),
		OPCODE: Opcode.new(:QUERY),

		RCODE: Status.new(:NOERROR),

		QDCOUNT: 0,
		ANCOUNT: 0,
		NSCOUNT: 0,
		ARCOUNT: 0
	}

	def self.id
		(rand * 100_000).to_i % 65536
	end

	def self.parse (string)
		data = string.unpack('nnnnnn')

		string[0, Header.length] = ''

		Header.new(
			ID: data[0],

			QR: Type.new((data[1] & 0x8000) >> 15),

			OPCODE: Opcode.new((data[1] & 0x7800) >> 11),

			AA: (data[1] & 0x400 != 0),
			TC: (data[1] & 0x200 != 0),
			RD: (data[1] & 0x100 != 0),
			RA: (data[1] & 0x80  != 0),
			AD: (data[1] & 0x40  != 0),
			CD: (data[1] & 0x20  != 0),

			RCODE: Status.new(data[1] & 0xf),

			QDCOUNT: data[2],
			ANCOUNT: data[3],
			NSCOUNT: data[4],
			ARCOUNT: data[5]
		)
	end

	def self.length (string = nil)
		12
	end

	def initialize (what = {})
		unless what.is_a? Hash
			raise ArgumentError, 'you have to pass a Hash.'
		end

		@data = Default.merge(ID: Header.id).merge(what)

		yield self if block_given?
	end

	def id;             @data[:ID]      end
	def type;           @data[:QR]      end
	def class;          @data[:OPCODE]  end
	def authoritative?; @data[:AA]      end
	def truncated?;     @data[:TC]      end
	def recursive?;     @data[:RD]      end
	def recursivable?;  @data[:RA]      end
	def authentic?;     @data[:AD]      end
	def checking?;      @data[:CD]      end
	def status;         @data[:RCODE]   end
	def questions;      @data[:QDCOUNT] end
	def answers;        @data[:ANCOUNT] end
	def authorities;    @data[:NSCOUNT] end
	def additionals;    @data[:ARCOUNT] end

	def id= (val);          @data[:ID]      = val;             end
	def type= (val);        @data[:QR]      = Type.new(val);   end
	def class= (val);       @data[:OPCODE]  = Opcode.new(val); end
	def authoritative!;     @data[:AA]      = true;            end
	def truncated!;         @data[:TC]      = true;            end
	def recursive!;         @data[:RD]      = true;            end
	def recursivable!;      @data[:RA]      = true;            end
	def authentic!;         @data[:AD]      = true;            end
	def checking!;          @data[:CD]      = true;            end
	def not_authoritative!; @data[:AA]      = false;           end
	def not_truncated!;     @data[:TC]      = false;           end
	def not_recursive!;     @data[:RD]      = false;           end
	def not_recursivable!;  @data[:RA]      = false;           end
	def not_authentic!;     @data[:AD]      = false;           end
	def not_checking!;      @data[:CD]      = false;           end
	def status= (val);      @data[:RCODE]   = Status.new(val); end
	def questions= (val);   @data[:QDCOUNT] = val;             end
	def answers= (val);     @data[:ANCOUNT] = val;             end
	def authorities= (val); @data[:NSCOUNT] = val;             end
	def additionals= (val); @data[:ARCOUNT] = val;             end

	alias klass class

	def pack
		[
			id,

			( (type.value << 15) \
			| (klass.value << 14) \
			| ((authoritative?) ? (1 << 10) : 0) \
			| ((truncated?) ? (1 << 9) : 0) \
			| ((recursive?) ? (1 << 8) : 0) \
			| ((recursivable?) ? (1 << 7) : 0) \
			| (status.value)),

			questions,
			answers,
			authorities,
			additionals
		].pack('nnnnnn')
	end

	def inspect
		"#<Header:(#{id}) #{type} #{klass} #{status} [#{questions} questions, #{answers} answers, #{authorities} authorities, #{additionals} additionals]#{tmp = [('authoritative' if authoritative?), ('truncated' if truncated?), ('recursive' if recursive?), ('recursivable' if recursivable?), ('authentic' if authentic?), ('checking' if checking?)].compact.join(' '); " (#{tmp})" if !tmp.empty?}>"
	end
end

end

