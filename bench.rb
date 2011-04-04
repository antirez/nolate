def bench(descr, times)
    start = Time.now.to_f
    times.times { yield }
    elapsed = Time.now.to_f - start
    reqsec = times / elapsed
    puts "#{descr.ljust(25)}: #{(reqsec).to_i.to_s.rjust(10)} requests/second"
    $template = ""
end

TEMPLATE = <<-TEMPLATE * 3
<html>
<body>
Long template with all the features Yeah!. 2 + 2 is: <%= # 2+2 = 4
2+2
%>

<%= @x %>

<% @x %>

<%#periquin%>

<% (1..2).each{|x| %>
Number <%= x %>
<% } %>

</body></html>
TEMPLATE

TIMES = 30_000

if ARGV[0] == "n"
    load 'nolate.rb'
    puts("nolate")
    bench("empty template"          , TIMES) { nolate("") }
    bench("small constant template" , TIMES) { nolate("nosub") }
    bench("simple substitution"     , TIMES) { nolate("simple <%= 'sub' %>") }
    bench("hash substitution"       , TIMES) { nolate("hash sub <%#x%>") }
    bench("testview2 file template" , TIMES) { nlt(:testview2) }
    bench("big template (#{TEMPLATE.length} bytes)", TIMES) { @x = 1; nolate(TEMPLATE, :x => 1) }
else
    load 'nolatep.rb'
    include Nolatep
    puts("\nnolate with 'parser'")
    t = nlt_parse("")                    ; bench("empty template"          , TIMES) { nlt_eval(t) }
    t = nlt_parse("nosub")               ; bench("small constant template" , TIMES) { nlt_eval(t) }
    t = nlt_parse("simple <%= 'sub' %>") ; bench("simple substitution"     , TIMES) { nlt_eval(t) }
    t = nlt_parse("hash sub <%#x%>")     ; bench("hash substitution"       , TIMES) { nlt_eval(t) }
    bench("testview2 file template" , TIMES) { Nolatep.nlt(:testview2) }
    t = nlt_parse(TEMPLATE)              ; bench("big template (#{TEMPLATE.length} bytes)", TIMES) { @x = 1; nlt_eval(t, :x => 1) }
end
