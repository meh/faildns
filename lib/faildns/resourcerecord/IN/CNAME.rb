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

require 'faildns/domainname'

module DNS

class ResourceRecord

module IN

#--
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     /                     CNAME                     /
#     /                                               /
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#
# where:
#
# CNAME           A <domain-name> which specifies the canonical or primary
#                 name for the owner.  The owner name is an alias.
#
# CNAME RRs cause no additional section processing, but name servers may
# choose to restart the query at the canonical name in certain cases.  See
# the description of name server logic in [RFC-1034] for details.
#++

class CNAME < Data
	def self._unpack (string, original)
		CNAME.new(DomainName.parse(string.clone, original))
	end

	attr_reader :domain

	def initialize (domain)
		@domain = DomainName.new(domain)
	end

	hash_on :@domain

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
