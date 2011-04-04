load 'nolate.rb'
load 'nolatep.rb'

def bench(descr, times)
    start = Time.now.to_f
    times.times { yield }
    elapsed = Time.now.to_f - start
    reqsec = times / elapsed
    puts "#{descr.ljust(25)}: #{(reqsec/1000).to_i.to_s.rjust(6)}K requests/second"
    $template = ""
end

TIMES = 100_000

puts("nolate")
bench("empty template"          , TIMES) { nolate("") }
bench("small constant template" , TIMES) { nolate("nosub") }
bench("simple substitution"     , TIMES) { nolate("simple <%= 'sub' %>") }
bench("hash substitution"       , TIMES) { nolate("hash sub <%#x%>") }
bench("testview2 file template" , TIMES) { nlt(:testview2) }

include Nolatep
puts("\nnolatep")
t = nlt_parse("")                    ; bench("empty template"          , TIMES) { nlt_eval(t) }
t = nlt_parse("nosub")               ; bench("small constant template" , TIMES) { nlt_eval(t) }
t = nlt_parse("simple <%= 'sub' %>") ; bench("simple substitution"     , TIMES) { nlt_eval(t) }
t = nlt_parse("hash sub <%#x%>")     ; bench("hash substitution"       , TIMES) { nlt_eval(t) }
bench("testview2 file template" , TIMES) { Nolatep.nlt(:testview2) }
