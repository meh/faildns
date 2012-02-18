Kernel.load 'lib/faildns/version.rb'

Gem::Specification.new {|s|
	s.name         = 'faildns'
	s.version      = DNS::VERSION
	s.author       = 'meh.'
	s.email        = 'meh@paranoici.org'
	s.homepage     = 'http://github.com/meh/faildns'
	s.platform     = Gem::Platform::RUBY
	s.summary      = 'A fail DNS library.'

	s.files         = `git ls-files`.split("\n")
	s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
	s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
	s.require_paths = ['lib']

	s.add_dependency 'threadpool'
	s.add_dependency 'simpleidn'

	s.add_development_dependency 'rake'
	s.add_development_dependency 'rspec'
}
