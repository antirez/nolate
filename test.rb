require 'test/unit'
load 'lib/nolate.rb'

class MyExampleClass
    def method_one
        @x = "Hello"
        nolate("<%= @x %>")
    end

    def method_two
        @x = "World"
        nlt(:testview3)
    end
end

class NolateTest < Test::Unit::TestCase
    def test_basic
        assert_equal("",nolate(""))
        assert_equal("nosub",nolate("nosub"))
        assert_equal("simple sub",nolate("simple <%= 'sub' %>"))
        assert_equal("hash sub 1",nolate("hash sub <%#x%>",{:x => 1}))
        assert_equal("just eval",nolate("just ev<% 'sub' %>al"))
        assert_equal("test 4 view\n",nlt(:testview))
        assert_equal("test 4 view\n",nlt("testview.nlt"))
        assert_equal("<html>\n<body>\n4\n</body>\n</html>\n",nlt(:testview2))
        assert_equal("3",nolate("<%x=2%><%=x+1%>"))
        assert_equal("Hello",MyExampleClass.new.method_one)
        assert_equal("World\n",MyExampleClass.new.method_two)
        assert_equal("\n1\n\n4\n\n9\n\n[1, 4, 9]\n",nlt(:testview6))
        assert_equal("zap\n\n4\nciao\n",nlt(:testview7))
    end

    def test_iter
        assert_equal(<<-OUTPUT, nlt(:testview4))
Number 1
Number 2
Number 3
Number 4

OUTPUT
    end

    def test_layout
        nlt_set_layout(:layout)
        assert_equal("Header\n2+2=4\nFooter\n",nolate("2+2=<%= 2+2 %>"))
        nlt_set_layout(:layout2)
        assert_equal("Header\nciao\nnested call\nFooter\n",nolate("ciao"))
        nlt_set_layout(:layout)
        assert_equal("2+2=4",nolate("2+2=<%= 2+2 %>",{},{:layout => false}))
        assert_equal("Other Header\n2+2=4\nOther Footer\n",
                     nolate("2+2=<%= 2+2 %>",{},{:layout => :layout3}))
    end

    def test_error_lines
        # Make sure that compiled template and template have the code in the
        # same lines, so that eval() will report good error traces.
        text = File.read("views/testview5.nlt").to_a
        compiled = nlt_compile(File.read("views/testview5.nlt")).split("\n")
        assert(text[3] =~ /title/ && compiled[3] =~ /title/)
        assert(text[8] =~ /each/ && compiled[8] =~ /each/)
        assert(text[22] =~ /4\+4/ && compiled[22] =~ /4\+4/)
        assert(text[29] =~ /ivar/ && compiled[29] =~ /ivar/)
        assert(text[36] =~ /else/ && compiled[36] =~ /else/)
    end
end
