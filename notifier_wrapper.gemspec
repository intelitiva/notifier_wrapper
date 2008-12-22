require 'rake'

Gem::Specification.new do |spec|
  spec.name = %q{notifier_wrapper}
  spec.version = "0.1.0"
  spec.date = %q{2008-12-22}
  spec.authors = ["Vicente Mundim"]
  spec.email = ["vicente.mundim@intelitiva.com"]
  spec.homepage = "http://github.com/intelitiva/notifier_wrapper"
  spec.summary = %q{A wrapper for notifiers in various plataforms.}
  spec.has_rdoc = true
  spec.description = %q{A wrapper for notifiers in various plataforms.}
  spec.files = FileList['lib/**/*', "README", "LICENSE"].to_a
  spec.test_files = Dir.glob('test/*.rb')
  spec.rubyforge_project = 'notifier_wrapper'
end
