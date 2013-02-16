Gem::Specification.new do |s|
  s.name = 'qcp'
  s.version = eval(File.read('lib/qcp/version.rb'))
  s.executables << 'qcp'
  s.date = Time.now.strftime('%Y-%m-%d')
  s.summary = 'Internet clipboard from the command-line.'
  s.description = 'Internet clipboard from the command-line. Copy files and data between machines easily.'
  s.authors = ['Chris Schmich']
  s.email = 'schmch@gmail.com'
  s.files = Dir['{lib}/**/*.rb', 'bin/*', '*.md']
  s.require_path = 'lib'
  s.homepage = 'https://github.com/schmich/qcp'
  s.required_ruby_version = '>= 1.9.3'
  s.add_runtime_dependency 'passgen', '~> 1.0.2'
  s.add_runtime_dependency 'rest-client', '~> 1.6.7'
  s.add_runtime_dependency 'addressable', '~> 2.3.2'
  s.add_runtime_dependency 'json', '~> 1.7.6'
  s.add_development_dependency 'rake', '>= 0.9.2.2'
  s.post_install_message = <<END
-------------------------------
Run 'qcp help' to get started.
-------------------------------
END
end
