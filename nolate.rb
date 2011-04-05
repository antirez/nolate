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
    $templates ||= {}
end

def nlt_flush_templates
    $templates = {}
end

def nlt_parse(str)
    i = -1  # I wish I had map.with_index in 1.8 :(
    prev_was_eval = false # Previous token was an :eval?
    str.split(/<%(.*?)%>/m).map do |s|
        i, first_char = i + 1, s[0..0]
        if i % 2 == 0
            j = 0
            if prev_was_eval and s != "\n" and s != "\r\n"
                j += 1 if s[j..j] == "\r"
                j += 1 if s[j..j] == "\n"
            end
            prev_was_eval = false
            [s[j..-1].inspect]
        elsif first_char == "="
            prev_was_eval = false
            [:evalo, s[1..-1]]
        elsif first_char == "#"
            prev_was_eval = false
            [:sub,   s[1..-1].to_sym]
        else
            prev_was_eval = true
            [:eval,  s]
        end
    end
end

def nlt_compile(template,sub)
    s = "__=[]\n"
    nlt_parse(template).each do |action, param|
        case action
            when :evalo then s << "__<<(#{param}).to_s\n"
            when :eval  then s << "#{param}\n"
            when :sub   then s << "__<< __sub[#{param.to_sym.inspect}]\n"
            else             s << "__<<#{action}\n"
        end
    end
    s << "__.join"
end

def nlt_eval(code, sub = {})
    eval(code, nlt_empty_binding(sub), __FILE__, __LINE__)
end

def nlt(viewname, sub={})
    viewname = "#{viewname}.nlt" if viewname.is_a?(Symbol)
    unless nlt_templates[viewname]
        filename = "views/#{viewname}"
        raise "NOLATE error: no template at #{filename}" \
            unless File.exists?(filename)
        nlt_templates[viewname] = nlt_compile(File.read(filename).chomp,sub)
    end
    nlt_eval(nlt_templates[viewname], sub)
end

def nolate(str, sub={})
    nlt_eval(nlt_compile(str,sub), sub)
end
