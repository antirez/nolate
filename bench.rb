load 'nolate.rb'

def bench(descr,times)
    start = Time.now.to_f
    times.times { yield }
    elapsed = Time.now.to_f - start
    reqsec = times / elapsed
    puts "#{descr}: #{reqsec} requests/second"
end

bench("empty template",30000) {
    nolate("")
}

bench("small constant template",30000) {
    nolate("nosub")
}

bench("simple substitution",30000) {
    nolate("simple <%= 'sub' %>")
}

bench("hash substitution",30000) {
    nolate("hash sub <%#x%>")
}

bench("testview2 file template",30000) {
    nlt(:testview2)
}
