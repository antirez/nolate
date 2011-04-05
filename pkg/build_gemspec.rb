class GemIt
    def initialize
        @template = File.read("pkg/gemspec_template.rb")
    end
    def list_files(path,parent=nil)
        files = []
        dir = Dir.open(path)
        dir.to_a.each{|f|
            next if f[0..0] == "."
            if File.directory? f
                files += list_files("#{path}/#{f}","#{f}")
            else
                files << (parent ? "#{parent}/#{f}" : f)
            end
        }
        files
    end
    def gemspec
        files = GemIt.new.list_files(".")
        version = File.read("VERSION").chomp
        gemspec = @template
        gemspec.sub!("%version%",version.inspect)
        gemspec.sub!("%files%",files.inspect)
    end
end

gemspec = GemIt.new.gemspec
f = File.open("nolate.gemspec","w").write(gemspec)
