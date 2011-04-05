# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=

  s.name = %q{nolate}
  s.version = "0.0.1"
  s.summary = %q{Ruby Template System}
  s.description = %q{Pure Ruby template engine optimized for speed}
  s.authors = ["Salvatore Sanfilippo","Michel Martens","Bruno Michel","Emmanuel Oga"]
  s.autorequire = %q{nolate}
  s.date = %q{2011-04-05}
  s.email = %q{antirez@gmail.com}
  s.extra_rdoc_files = ["LICENSE"]
  s.homepage = %q{http://github.com/antirez/nolaote}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.5.0}

  s.files = %w{
    LICENSE
    README
    bench.rb
    example.rb
    nolate.gemspec
    test.rb
    lib/nolate.rb
    views/bigtemplate.nlt
    views/example.nlt
    views/layout.nlt
    views/layout2.nlt
    views/layout3.nlt
    views/testview.nlt
    views/testview2.nlt
    views/testview3.nlt
    views/testview4.nlt
    views/testview5.nlt
  }
end
