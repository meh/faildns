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
	DNS   = ::DNS::Client::Resolver::DNS
	Hosts = ::DNS::Client::Resolver::Hosts

	%w[getaddress getaddresses each_address getname getnames each_name].each {|name|
		define_singleton_method name do |*args, &block|
			(@resolv ||= Resolv.new).__send__ name, *args, &block
		end
	}

	def initialize (resolvers = nil)
		@client = ::DNS::Client.new(resolvers: resolvers)
	end

	def getaddress (name)
		@client.resolve(name).first
	end

	def getaddresses (name)
		@client.resolve(name)
	end

	def each_address (name, &block)
		getaddresses(name).each(&block)
	end

	def getname (address)
		@client.resolve(address, reverse: true).first
	end

	def getnames (address)
		@client.resolve(address, reverse: true)
	end

	def each_name (address, &block)
		getnames(address).each(&block)
	end
end
