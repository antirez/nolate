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
module Nolatep
  extend self

  def nlt_empty_binding
    return binding()
  end

  def nlt_templates
    @templates ||= {}
  end

  def nlt_flush_templates
    @templates = {}
  end

  def nlt_parse(str)
    i = -1  # I wish I had map.with_index in 1.8 :(
    str.split(/<%(.*?)%>/m).map do |s|
      i, first_char = i + 1, s[0..0]
      if    i % 2 == 0        then [s.inspect]
      elsif first_char == "=" then [:evalo, s[1..-1]]
      elsif first_char == "#" then [:sub,   s[1..-1].to_sym]
      else                         [:eval,  s]
      end
    end
  end

  def nlt_eval(template, sub = {}, b = nlt_empty_binding)
    s = "__=[]\n"
    template.each do |action, param|
      case action
      when :evalo then s << "__<<(#{param}).to_s\n"
      when :eval  then s << "#{param}\n"
      when :sub   then s << "__<<#{sub[param].to_s.inspect}\n"
      else             s << "__<<#{action}\n"
      end
    end
    eval(s << "__.join", b, __FILE__, __LINE__)
  end

  def nlt(viewname, sub={}, b = nlt_empty_binding)
    viewname = "#{viewname}.nlt" if viewname.is_a?(Symbol)
    unless nlt_templates[viewname]
      filename = "views/#{viewname}"
      raise "NOLATE error: no template at #{filename}" unless File.exists?(filename)
      nlt_templates[viewname] = nlt_parse(File.read(filename).chomp)
    end
    nlt_eval(nlt_templates[viewname], sub, b)
  end

  def nolate(str, sub={})
    nlt_eval(nlt_parse(str), sub, binding)
  end
end
