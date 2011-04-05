load 'lib/nolate.rb'

hash = {:title => "Hello World!"}
@ivar = "Instance Variable Content"
puts nlt(:example,hash) # Check views/example.nlt for more info
