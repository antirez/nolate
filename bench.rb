load "lib/nolate.rb"

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

bench("empty template"          , TIMES) { nolate("") }
bench("small constant template" , TIMES) { nolate("nosub") }
bench("simple substitution"     , TIMES) { nolate("simple <%= 'sub' %>") }
bench("hash substitution"       , TIMES) { nolate("hash sub <%#x%>") }
bench("testview2 file template" , TIMES) { nlt(:testview2) }
bench("big template .nlt", TIMES/5) { @x = 1; nlt(:bigtemplate, :x => 1) }
bench("big template (#{TEMPLATE.length} bytes)", TIMES/10) { @x = 1; nolate(TEMPLATE, :x => 1) }
