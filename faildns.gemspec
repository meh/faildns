Gem::Specification.new {|s|
    s.name         = 'faildns'
    s.version      = '0.0.1'
    s.author       = 'meh.'
    s.email        = 'meh@paranoici.org'
    s.homepage     = 'http://github.com/meh/faildns'
    s.platform     = Gem::Platform::RUBY
    s.description  = 'A fail DNS library, Server and Client.'
    s.summary      = 'A fail DNS library.'
    s.files        = Dir.glob('lib/**/*.rb')
    s.require_path = 'lib'
    s.executables  = []
    s.has_rdoc     = true
}
