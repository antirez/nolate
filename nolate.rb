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

$nlt_templates = {}

def nolate_empty_binding
    return binding()
end

def nolate_compile(__template,__sub={})
    __i = 0
    __l = __template.length
    __result = '__nolate_html=""'+"\n"
    while __i < __l
        # Find start: <%
        __start = __template.index("<%",__i)
        # Emit everything from the last index to the start as a plain string.
        if __start != 0 or !__start
            __s = __start ? __start-1 : -1
            __content = __template[(__i..__s)]
            __content.chop! if __content[-1..-1] == "\n"
            __content.chop! if __content[-1..-1] == "\r"
            __result << "__nolate_html += "+__content.inspect+"\n"
            break if !__start
        end
        # Find stop: %>
        __i = __start+2
        __stop = __template.index("%>",__i)
        __stop = __l+1 if !__stop # Implicit %> at end of string...
        __i = __stop+2 # In the next iteration we start immediately after %>
        # Now we have the string to interpolate, <% ... %>
        # What we need to do is to check the first character to understand
        # The kind of interpolation to perform:
        # <%= ... %> means to eval the expression and substitute the result
        # <%#foo%>   means to substitute with sub[:foo]
        if __template[__start+2] == 61 or __template[__start+2] == '='
            __inter = __template[(__start+3)..(__stop-1)]
            __result << "__nolate_html += (\n"+__inter+"\n).to_s\n"
        elsif __template[__start+2] == 35 or __template[__start+2] == '#'
            __inter = __template[(__start+3)..(__stop-1)]
            __result << "__nolate_html += __sub["+(__inter.to_sym.inspect)+"].to_s\n"
        else
            __inter = __template[(__start+2)..(__stop-1)]
            __result << __inter+"\n"
        end
    end
    __result << '__nolate_html'+"\n"
    return __result
end

def nolate(__template,__sub={})
    compiled = nolate_compile(__template,__sub)
    return eval(compiled)
end

def nlt(viewname,sub={})
    viewname = viewname.to_s+".nlt" if viewname.is_a?(Symbol)
    if !$nlt_templates[viewname]
        filename = "views/"+viewname
        if !File.exists?(filename)
            raise "NOLATE error: no template at #{filename}"
        end
        $nlt_templates[viewname] = File.read(filename)
    end
    nolate($nlt_templates[viewname],sub)
end

def nlt_flush_templates
    $nlt_templates = {}
end
