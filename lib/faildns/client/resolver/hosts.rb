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

module DNS; module Resolver

class Hosts
	DefaultFileName = '/etc/hosts'

	def initialize (path = DefaultFileName)
		@path = path
	end

	def resolve (domain, options = nil)
		if DNS::IP.valid?(domain)
			name_for(domain)
		else
			address_for(domain)
		end
	end

private
	def address_for (name)
		File.read(@path).lines.find {|line|
			line =~ /^(.*?)\s*#{Regexp.escape(name)}$/
		} && $1
	end

	def name_for (address)
		File.read(@path).lines.find {|line|
			line =~ /^(#{Regexp.escape(address)}\s*(.*?)$/
		} && $1
	end
end

end; end
