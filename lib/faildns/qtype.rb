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

require 'faildns/type'

module DNS

#--
# QTYPE fields appear in the question part of a query.  QTYPES are a
# superset of TYPEs, hence all TYPEs are valid QTYPEs.  In addition, the
# following QTYPEs are defined:
# 
# 
# AXFR            252 A request for a transfer of an entire zone
# 
# MAILB           253 A request for mailbox-related records (MB, MG or MR)
# 
# MAILA           254 A request for mail agent RRs (Obsolete - see MX)
# 
# *               255 A request for all records
#++

class QType < Type
  Values = {
    252 => :AXFR,
    253 => :MAILB,
    254 => :MAILA,
    255 => :ANY
  }

  def initialize (value)
    super(value)
  end

  def to_sym
    Values[@value] || Class::Values[@value]
  end

  def to_s
    (Values[@value] || Class::Values[@value]).to_s
  end
end

end
