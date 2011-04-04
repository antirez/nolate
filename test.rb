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
        assert_equal(nolate(""),"")
        assert_equal(nolate("nosub"),"nosub")
        assert_equal(nolate("simple <%= 'sub' %>"),"simple sub")
        assert_equal(nolate("hash sub <%#x%>",{:x => 1}),"hash sub 1")
        assert_equal(nolate("just ev<%% 'sub' %>al"),"just eval")
        assert_equal(nlt(:testview),"test 4 view\n")
        assert_equal(nlt("testview.nlt"),"test 4 view\n")
        assert_equal(nlt(:testview2),"<html>\n<body>\n4\n</body>\n</html>\n")
        assert_equal(nolate("<% foo %>"),"<% foo %>")
        assert_equal(nolate("<%%x=2%><%=x+1%>"),"3")
        assert_equal(MyExampleClass.new.method_one,"Hello")
        assert_equal(MyExampleClass.new.method_two,"World\n")
    end
end
