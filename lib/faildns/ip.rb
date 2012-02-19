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

require 'ipaddr'

module DNS

class IP
	def self.valid? (string)
		IPAddr.new(string)

		true
	rescue
		false
	end

	def self.unpack (string)
		IP.new(IPAddr.new_ntoh(string))
	end

	include DNS::Comparable

	def initialize (what)
		if what.is_a?(String)
			@internal = IPAddr.new(what.to_s)
		elsif what.is_a?(IP)
			@internal = what.instance_variable_get :@internal
		elsif what.is_a?(IPAddr)
			@internal = what
		else
			DNS.debug what.inspect

			raise ArgumentError, 'wat is dis i dont even'
		end
	end

	hash_on :@internal

	def version
		@internal.ipv4? ? 4 : 6
	end

	def pack (*)
		@internal.hton
	end

	def to_s
		@internal.to_s
	end

	alias to_str to_s
end

end
