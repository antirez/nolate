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

def nolate(template,sub={})
    i = 0
    l = template.length
    result = ""
    while i < l
        # Find start: <%
        start = template.index("<%",i)
        if !start
            result << template[(i..-1)]
            return result
        end
        # Emit everything from the last index to the start as a plain string.
        result << template[(i..(start-1))] if start != 0
        # Find stop: %>
        i = start+2
        stop = template.index("%>",i)
        stop = l+1 if !stop # Implicit %> at end of string...
        i = stop+2 # In the next iteration we start immediately after %>
        inter = template[(start+3)..(stop-1)]
        # Now we have the string to interpolate, <% ... %>
        # What we need to do is to check the first character to understand
        # The kind of interpolaiton to perform:
        # <%= ... %> means to eval the expression and substitute the result
        # <%#foo%>   means to substitute with sub[:foo]
        if template[start+2] == 61
            result << eval(inter).to_s
        elsif template[start+2] == 35
            result << sub[inter.to_s.to_sym].to_s
        else
            raise "NOLATE template error near '#{template[(start)..(start+2)]}'"
        end
    end
    return result
end

def nlt(viewname,sub={})
    viewname = viewname.to_s
    if !$nlt_templates[viewname]
        filename = "views/"+viewname
        if !File.exists?(filename)
            raise "NOLATE error: no template at #{filename}"
        end
        $nlt_templates[viewname] = File.open(filename).read
    end
    nolate($nlt_templates[viewname],sub)
end

def nlt_flush_templates
    $nlt_templates = {}
end
