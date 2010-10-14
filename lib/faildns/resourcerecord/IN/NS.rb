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

#--
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
#     /                   NSDNAME                     /
#     /                                               /
#     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
# 
# where:
# 
# NSDNAME         A <domain-name> which specifies a host which should be
#                 authoritative for the specified class and domain.
# 
# NS records cause both the usual additional section processing to locate
# a type A record, and, when used in a referral, a special search of the
# zone in which they reside for glue information.
# 
# The NS RR states that the named host should be expected to have a zone
# starting at owner name of the specified class.  Note that the class may
# not indicate the protocol family which should be used to communicate
# with the host, although it is typically a strong hint.  For example,
# hosts which are name servers for either Internet (IN) or Hesiod (HS)
# class information are normally queried using IN class protocols.
#++

class ResourceRecord

module IN

class NS < Data
  def initialize (string, original)

  end
end

end

end

end
