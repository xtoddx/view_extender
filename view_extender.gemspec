Gem::Specification.new do |s|

  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new('>= 0') if s.respond_to? :required_rubygems_version=

  s.date = '2008-09-01'
  s.name = 'view_extender'
  s.version = '0.0.1'
  s.authors = ['Todd Willey']
  s.email = 'todd@rubidine.org'
  s.homepage = 'http://github.com/xtoddx/'
  s.summary = 'Allow plugins to put data in your views'
  s.description = 'Put <%= extension_point "point1" %> in your view wherever you want plugins to extend.  In plugins call ViewExtender.register(...).'

  s.require_paths = ['lib']

  s.has_rdoc = true
  s.extra_rdoc_files = ['README.markdown']
  s.rdoc_options = ["--line-numbers", "--inline-source", "--main", "README.markdown", "--title", "View Extender Rails Plugin"]

  s.files = Dir['lib/**/*'] + ['MIT-LICENSE', 'README.markdown', 'init.rb']
end
