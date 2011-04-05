test:
	ruby test.rb

gem:
	ruby pkg/build_gemspec.rb
	gem build nolate.gemspec
	mv -f *.gem pkg
