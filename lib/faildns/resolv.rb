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

require 'faildns/client'

class Resolv
	DNS   = ::DNS::Resolver::DNS
	Hosts = ::DNS::Resolver::Hosts

	def self.getaddress (name)
		Resolv.new.getaddress(name)
	end

	def self.getaddresses (name)
		Resolv.new.getaddresses(name)
	end

	def self.each_address (name, &block)
		Resolv.new.each_address(name, &block)
	end

	def initialize (resolvers = nil)
		@client = DNS::Client.new(resolvers: resolvers)
	end

	def getaddress (name)
		@client.resolve(name).first
	end

	def getaddresses (name)
		@client.resolve(name)
	end

	def each_address (name)
		getaddresses(name).each { |a| yield a }
	end
end
