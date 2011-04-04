require 'test/unit'
load 'nolate.rb'

class NolateTest < Test::Unit::TestCase
    def test_basic
        assert_equal(nolate(""),"")
        assert_equal(nolate("nosub"),"nosub")
        assert_equal(nolate("simple <%= 'sub' %>"),"simple sub")
        assert_equal(nolate("hash sub <%#x%>",{:x => 1}),"hash sub 1")
        assert_equal(nolate("just ev<%% 'sub' %>al"),"just eval")
        assert_equal(nlt(:testview),"test 4 view\n")
        assert_equal(nlt("testview.nlt"),"test 4 view\n")
    end
end
