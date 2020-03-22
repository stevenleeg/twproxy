Gem::Specification.new do |s|
  s.name = "twproxy"
  s.version = "0.0.1"
  s.date = "2016-04-09"
  s.summary = "TiddlyWiki Proxy"
  s.description = "An authenticated proxy for TiddlyWiki"
  s.authors = ["Steve Gattuso"]
  s.email = "steve@stevegattuso.me"
  s.files = ["lib/twproxy.rb"]
  s.files = %w(Gemfile LICENSE README.md twproxy.gemspec) + Dir['lib/**/*', 'bin/*']
  s.license = "MIT"
  s.executables << 'twproxy'

  s.add_dependency 'sinatra', '~> 1.4'
  s.add_dependency 'haml', '>= 4', '< 6'
  s.add_dependency 'rotp', '~> 2.1'
end

