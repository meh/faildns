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
# TYPE fields are used in resource records.  Note that these types are a
# subset of QTYPEs.
#
# TYPE            value and meaning
#
# A               1 a host address
#
# NS              2 an authoritative name server
#
# MD              3 a mail destination (Obsolete - use MX)
#
# MF              4 a mail forwarder (Obsolete - use MX)
#
# CNAME           5 the canonical name for an alias
#
# SOA             6 marks the start of a zone of authority
#
# MB              7 a mailbox domain name (EXPERIMENTAL)
#
# MG              8 a mail group member (EXPERIMENTAL)
#
# MR              9 a mail rename domain name (EXPERIMENTAL)
#
# NULL            10 a null RR (EXPERIMENTAL)
#
# WKS             11 a well known service description
#
# PTR             12 a domain name pointer
#
# HINFO           13 host information
#
# MINFO           14 mailbox or mail list information
#
# MX              15 mail exchange
#
# TXT             16 text strings
#++

class Type
	Values = {
		1  => :A,
		2  => :NS,
		3  => :MD,
		4  => :MF,
		5  => :CNAME,
		6  => :SOA,
		7  => :MB,
		8  => :MG,
		9  => :MR,
		10 => :NULL,
		11 => :WKS,
		12 => :PTR,
		13 => :HINFO,
		14 => :MINFO,
		15 => :MX,
		16 => :TXT,
		17 => :RP,
		18 => :AFSDB,
		19 => :X25,
		20 => :ISDN,
		21 => :RT,
		22 => :NSAP,
		23 => :NSAP_PTR,
		24 => :SIG,
		25 => :KEY,
		26 => :PX,
		27 => :GPOS,
		28 => :AAAA,
		29 => :LOC,
		30 => :NXT,
		31 => :EID,
		32 => :NIMLOC,
		33 => :SRV,
		34 => :ATMA,
		35 => :NAPTR,
		36 => :KX,
		37 => :CERT,
		38 => :A6,
		39 => :DNAME,
		40 => :SINK,
		41 => :OPT,
		42 => :APL,
		43 => :DS,
		44 => :SSHFP,
		45 => :IPSECKEY,
		46 => :RRSIG,
		47 => :NSEC,
		48 => :DNSKEY,
		49 => :DHCID,
		50 => :NSEC3,
		51 => :NSEC3PARAM,

		55 => :HIP,
		56 => :NINFO,
		57 => :RKEY,
		58 => :TALINK,

		99  => :SPF,
		100 => :UINFO,
		101 => :UID,
		102 => :GID,
		103 => :UNSPEC,

		249 => :TKEY,
		250 => :TSIG,
		251 => :IXFR,

		32768 => :TA,
		32769 => :DLV
	}

	def self.unpack (string)
		result = new(string.unpack('n').first)

		string[0, length] = ''

		return result
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
			@internal = value.to_i rescue nil
		end

		if !to_sym
			raise ArgumentError, 'the passed value is not a suitable type.'
		end
	end

	hash_on :to_i

	def pack
		[to_i].pack('n')
	end

	def == (what)
		if what.is_a? Symbol
			self.to_sym == what
		elsif value.is_a? Integer
			@internal == what
		else
			@internal == what.value rescue false
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
