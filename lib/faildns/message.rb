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

require 'faildns/common'
require 'faildns/header'
require 'faildns/question'
require 'faildns/resourcerecord'

module DNS

class Message
	def self.unpack (string)
		string.force_encoding 'BINARY'
		original = string.clone

		Message.new {|m|
			m.header = Header.unpack(string)

			1.upto(m.header.questions) {
				m.questions << Question.unpack(string, original);
			}

			1.upto(m.header.answers) {
				m.answers << ResourceRecord.unpack(string, original);
			}

			1.upto(m.header.authorities) {
				m.authorities << ResourceRecord.unpack(string, original);
			}

			1.upto(m.header.additionals) {
				m.additionals << ResourceRecord.unpack(string, original);
			}
		}
	end

	def self.length (string)
		string = string.clone
	end

	include DNS::Comparable

	attr_accessor :header
	attr_reader   :questions, :answers, :authorities, :additionals

	def initialize (header = nil, *args)
		@header = header

		@questions   = args.shift || []
		@answers     = args.shift || []
		@authorities = args.shift || []
		@additionals = args.shift || []

		yield self if block_given?
	end

	hash_on :@header, :@questions, :@answers, :@authorities, :@additionals

	def pack
		@header.questions   = @questions.length
		@header.answers     = @answers.length
		@header.authorities = @authorities.length
		@header.additionals = @additionals.length

		result = ''

		result << @header.pack

		[@questions, @answers, @authorities, @additionals].each {|part|
			part.each {|piece|
				result << piece.pack
			}
		}

		result
	end

	def inspect
		"#<Message: #{header.inspect} #{[("questions=#{questions.inspect}" if questions.length > 0), ("answers=#{answers.inspect}" if answers.length > 0), ("authorities=#{authorities.inspect}" if authorities.length > 0), ("additionals=#{additionals.inspect}" if additionals.length > 0)].compact.join(' ')}>"
	end
end

end
