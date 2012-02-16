#! /usr/bin/env ruby
require 'rubygems'
require 'faildns'
require 'resolv'

describe DNS::Client do
  let(:client) {
    DNS::Client.new(:servers => ['8.8.8.8'])
  }

  describe '#resolve' do
    it 'resolves google.com correctly' do
      client.resolve('google.com')
    end
  end
end
