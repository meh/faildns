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

module DNS; class Client; module Resolver

class Hosts
	DefaultFileName = '/etc/hosts'

	def initialize (path = DefaultFileName)
		@path = path
	end

	def resolve (domain, options = nil)
		options = { version: 4 }.merge(options || {})

		if options[:reverse]
			names_for(domain)
		else
			addresses_for(domain)
		end
	end

private
	def addresses_for (name)
		File.read(@path).lines.map {|line|
			line.match /^(.*?)\s*#{Regexp.escape(name)}$/
		}.compact.map { |m| IP.new(m) }
	end

	def names_for (address)
		File.read(@path).lines.map {|line|
			line.match /^#{Regexp.escape(address)}\s*(.*?)$/
		}.compact.map { |m| DomainName.new(m) }
	end
end

end; end; end
