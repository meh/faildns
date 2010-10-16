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
  def self.parse (string)
    string.force_encoding 'BINARY'
    original = string.clone

    header = Header.parse(string);

    questions = []
    1.upto(header.questions) {
      questions << Question.parse(string, original);
    }

    answers = []
    1.upto(header.answers) {
      answers << ResourceRecord.parse(string, original);
    }

    authorities = []
    1.upto(header.authorities) {
      authorities << ResourceRecord.parse(string, original);
    }

    additionals = []
    1.upto(header.additionals) {
      additionals << ResourceRecord.parse(string, original);
    }

    Message.new(header, questions, answers, authorities, additionals)
  end

  def self.length (string)
    string = string.clone
  end

  attr_reader :header, :questions, :answers, :authorities, :additionals

  def initialize (*args)
    if args.length > 1
      @header, @questions, @answers, @authorities, @additionals = *(args.concat([[], [], [], []]))
    else
      raise ArgumentError.new('You have to pass at least 1 parameter.')
    end

    if block_given?
      yield self
    end
  end

  def pack
    result = ''

    result += @header.pack

    @questions.each {|question|
      result += question.pack
    }

    @answers.each {|answer|
      result += answer.pack
    }

    @authorities.each {|authority|
      result += answer.pack
    }

    @additionals.each {|additional|
      result += additional.pack
    }

    return result
  end
end

end
