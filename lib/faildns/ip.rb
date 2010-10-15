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

class IP
  def initialize (what)
    if what.is_a? String
      @value = what
    elsif what.is_a? Integer
      @value = [what].pack('N').unpack('CCCC').join('.')
    end
  end

  def pack
    @value.split('.').map{|part| part.to_i}.pack('CCCC')
  end

  def to_s
    @value
  end
end

end
