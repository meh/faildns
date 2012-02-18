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

require 'faildns/domainname'
require 'faildns/qtype'
require 'faildns/qclass'

module DNS

#--
# The question section is used to carry the "question" in most queries,
# i.e., the parameters that define what is being asked.  The section
# contains QDCOUNT (usually 1) entries, each of the following format:
#
#                                     1  1  1  1  1  1
#       0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     |                                               |
#     /                     QNAME                     /
#     /                                               /
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     |                     QTYPE                     |
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     |                     QCLASS                    |
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#
# where:
#
# QNAME           a domain name represented as a sequence of labels, where
#                 each label consists of a length octet followed by that
#                 number of octets.  The domain name terminates with the
#                 zero length octet for the null label of the root.  Note
#                 that this field may be an odd number of octets; no
#                 padding is used.
#
# QTYPE           a two octet code which specifies the type of the query.
#                 The values for this field include all codes valid for a
#                 TYPE field, together with some more general codes which
#                 can match more than one type of RR.
#
# QCLASS          a two octet code that specifies the class of the query.
#                 For example, the QCLASS field is IN for the Internet.
#++

class Question
	def self.unpack (string, original)
		Question.new {|q|
			q.name  = DomainName.unpack(string, original);
			q.type  = QType.unpack(string);
			q.class = QClass.unpack(string);
		}
	end

	def self.length (string)
		DomainName.length(string) + QType.length + QClass.length
	end

	include DNS::Comparable

	def initialize (what = {})
		unless what.is_a? Hash
			raise ArgumentError, 'you have to pass a Hash.'
		end

		@data = what

		yield self if block_given?
	end

	hash_on :@data

	def name;  @data[:QNAME]  end
	def type;  @data[:QTYPE]  end
	def class; @data[:QCLASS] end

	def name= (val);  @data[:QNAME]  = DomainName.new(val); end
	def type= (val);  @data[:QTYPE]  = QType.new(val);      end
	def class= (val); @data[:QCLASS] = QClass.new(val);     end

	alias klass class

	def pack
		name.pack + type.pack + klass.pack
	end

	def inspect
		"#<Question: #{name} #{klass} #{type}>"
	end
end

end
