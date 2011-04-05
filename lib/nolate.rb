# NOLATE, A NO LAme TEmplate system
#
# Please read the README file for more information
#
# Copyright (c) 2011, Salvatore Sanfilippo <antirez at gmail dot com>
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#  *  Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#
#  *  Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

def nlt_empty_binding(__sub_)
    __sub = __sub_
    return binding()
end

def nlt_templates
    $nolate_templates ||= {}
end

def nlt_flush_templates
    $nolate_templates = {}
end

def nlt_set_layout(layout)
    $nolate_layout = layout
end

def nlt_parse(str)
    i = -1  # I wish I had map.with_index in 1.8 :(
    prev_was_eval = false # Previous token was an :eval?
    str.split(/<%(.*?)%>/m).map do |s|
        i, first_char = i + 1, s[0..0]
        newlines = s.count("\n")
        if i % 2 == 0
            j = 0
            if prev_was_eval and s != "\n" and s != "\r\n"
                j += 1 if s[j..j] == "\r"
                j += 1 if s[j..j] == "\n"
            end
            prev_was_eval = false
            [:verb, s[j..-1].inspect, newlines]
        elsif first_char == "="
            prev_was_eval = false
            [:evalo, s[1..-1], newlines]
        elsif first_char == "#"
            prev_was_eval = false
            [:sub,   s[1..-1].to_sym, newlines]
        else
            prev_was_eval = true
            [:eval,  s, 0]
        end
    end
end

def nlt_compile(template)
    s = "__=[]; "
    nlt_parse(template).each do |action, param, newlines|
        case action
            when :evalo then s << "__<<(#{param}).to_s; "
            when :eval  then s << "#{param}; "
            when :sub   then s << "__<< __sub[#{param.to_sym.inspect}]; "
            when :verb  then s << "__<<#{param}; "
        end
        s << "\n"*newlines
    end
    s << "\n__.join"
end

def nlt_eval(code, sub = {}, opt = {}, file="evaluated_string")
    # Make sure that nested calls will not substitute the layout
    saved = @nolate_no_layout
    @nolate_no_layout = true
    content = eval(code, nlt_empty_binding(sub), file, 1)
    @nolate_no_layout = saved

    # And... make sure that the layout will not trigger an infinite recursion
    # substituting itself forever.
    if $nolate_layout and !@nolate_no_layout and !(opt[:layout] == false)
        saved = $nolate_layout
        if !opt[:layout]
            use = $nolate_layout
        else
            use = opt[:layout]
        end
        $nolate_layout = nil
        content = nlt(use,{:content => content})
        $nolate_layout = saved
    end
    content
end

def nlt(viewname, sub={}, opt={})
    viewname = "#{viewname}.nlt" if viewname.is_a?(Symbol)
    unless nlt_templates[viewname]
        filename = "views/#{viewname}"
        raise "NOLATE error: no template at #{filename}" \
            unless File.exists?(filename)
        nlt_templates[viewname] = nlt_compile(File.read(filename))
    end
    nlt_eval(nlt_templates[viewname], sub, opt, "views/#{viewname}")
end

def nolate(str, sub={}, opt={})
    nlt_eval(nlt_compile(str), sub, opt)
end
