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

require 'faildns/extensions'

require 'faildns/header'
require 'faildns/question'
require 'faildns/resourcerecord'

module DNS

class Message
	def self.unpack (string)
		string.force_encoding 'BINARY'
		original = string.dup

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
		string = string.dup
	end

	class Compression
		def initialize (message)
			@message = message

			@domains = {}
		end

		def method_missing (*args, &block)
			@message.__send__ *args, &block
		end

		def pointer_for (domain, offset)
			pieces = domain.to_s.split '.'

			if tmp = @domains[pieces]
				return [], tmp
			else
				unique  = nil
				pointer = nil

				@domains.each { |parts, offset|
					next if parts.length == pieces.length

					if parts.length > pieces.length
						if parts[parts.length - pieces.length .. -1] == pieces
							tmp = parts[0 ... parts.length - pieces.length]

							unique  = []
							pointer = offset + tmp.join.length + tmp.length

							break
						end
					else
						if pieces[pieces.length - parts.length .. -1] == parts
							unique  = pieces[0 ... pieces.length - parts.length]
							pointer = offset

							break
						end
					end
				}

				@domains[pieces] = offset

				unique = pieces unless unique

				return unique, pointer
			end
		end
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

		compress!

		yield self if block_given?
	end

	hash_on :@header, :@questions, :@answers, :@authorities, :@additionals

	def compress?;    @compress;         end
	def compress!;    @compress = true;  end
	def no_compress!; @compress = false; end

	def pack (*)
		@header.questions   = @questions.length
		@header.answers     = @answers.length
		@header.authorities = @authorities.length
		@header.additionals = @additionals.length

		message = compress? ? Compression.new(self) : self

		result = ''

		result << @header.pack(message, 0)

		[@questions, @answers, @authorities, @additionals].each {|part|
			part.each {|piece|
				result << piece.pack(message, result.length)
			}
		}

		result
	end

	def inspect
		"#<Message: #{header.inspect} #{[("questions=#{questions.inspect}" if questions.length > 0), ("answers=#{answers.inspect}" if answers.length > 0), ("authorities=#{authorities.inspect}" if authorities.length > 0), ("additionals=#{additionals.inspect}" if additionals.length > 0)].compact.join(' ')}>"
	end
end

end
