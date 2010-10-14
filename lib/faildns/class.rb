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
# CLASS fields appear in resource records.  The following CLASS mnemonics
# and values are defined:
# 
# IN              1 the Internet
# 
# CS              2 the CSNET class (Obsolete - used only for examples in
#                 some obsolete RFCs)
# 
# CH              3 the CHAOS class
# 
# HS              4 Hesiod [Dyer 87]
#++

class Class
  Values = {
    1 => :IN,
    2 => :CS,
    3 => :CH,
    4 => :HS
  }

  attr_reader :value

  def initialize (value)
    if value.is_a? Symbol
      @value = Values.find {|key, val| val == value}.first rescue nil
    else
      @value = value
    end

    if !self.to_sym
      raise ArgumentError.new('The passed value is not a suitable class.')
    end
  end

  def to_sym
    Values[@value]
  end

  def to_s
    Values[@value].to_s
  end
end

end
