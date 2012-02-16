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

require 'faildns/class'

module DNS

#--
# QCLASS fields appear in the question section of a query.  QCLASS values
# are a superset of CLASS values; every CLASS is a valid QCLASS.  In
# addition to CLASS values, the following QCLASSes are defined:
#
# *               255 any class
#++

class QClass < Class
	Values = {
		254 => :NONE,
		255 => :ANY
	}

	def initialize (value)
		super(value)
	end

	def to_sym
		Values[@value] || Class::Values[@value]
	end

	def to_s
		to_sym.to_s
	end
end

end
