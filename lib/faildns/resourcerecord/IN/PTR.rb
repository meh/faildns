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
#     /                   PTRDNAME                    /
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#
# where:
#
# PTRDNAME        A <domain-name> which points to some location in the
#                 domain name space.
#
# PTR records cause no additional section processing.  These RRs are used
# in special domains to point to some other location in the domain space.
# These records are simple data, and don't imply any special processing
# similar to that performed by CNAME, which identifies aliases.  See the
# description of the IN-ADDR.ARPA domain for an example.
#++

class PTR < Data
	def self._parse (string, original)
		PTR.new(DomainName.parse(string.clone, original))
	end

	attr_reader :domain

	def initialize (domain)
		@domain = domain
	end

	def pack
		@domain.pack
	end

	def length
		pack.length
	end

	def to_s
		@domain.to_s
	end
end

end

end

end
