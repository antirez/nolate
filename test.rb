require 'test/unit'
load 'nolate.rb'

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
    end
end
