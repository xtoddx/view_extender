# Copyright (c) 2008 Todd Willey <todd@rubidine.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'singleton'

#
# This module gets included into ActionView::Base in init.rb, making
# the instance method extension_point available in your views.  See
# README.markdown for an example of how to add to a view.
#
module ViewExtender

  #
  # This is how a plugin (or other extension method) will inject
  # into your view.
  #
  # ViewExtender.register('named_point', "String to display")
  #
  # ViewExtender.register('named_point', :partial => 'my_partial')
  #
  # ViewExtender.register('named_point') do 
  #   Config.show_foo? ? '' : {:partial => 'foo' }
  # end
  #
  def self.register key, *render_args, &blk
    (Registry.instance[key] ||= []) << (blk || render_args)
  end

  #
  # If an extension point is no longer needed, it can be removed.
  # Call with the same arguments it was added with.
  #
  # If using a block, you will need to have it saved as a proc,
  # because it will need to match exactly.
  #
  # prc = lambda{ something? ? "You have something" : {:partial => 'nothing'} }
  # ViewExtender.register &prc
  # ViewExtender.unregister &prc
  #
  def self.unregister key, *render_args, &blk
    return unless Registry.instance[key]
    Registry.instance[key].delete(blk || render_args)
  end

  #
  # In your view files, call this anywhere the veiw could be extended.
  # The argument 'key' is whatever you would like to name this extension point.
  #
  # In your view:
  #   <%= extension_point 'index:before_list' %>
  #
  # In a plugin or anywhere else you'd like to add an extension:
  #   ViewExtender.register('index:before_list', '<h3>Your List</h3>')
  #
  def extension_point key
    if Registry.instance[key]
      Registry.instance[key].collect do |render_args|
        if render_args.is_a?(Proc)
          render(render_args.call)
        elsif render_args.length == 1 and render_args.first.is_a?(String)
          render_args.first
        else
          render *render_args
        end
      end.join("\n")
    end
  end

  class Registry < Hash # :nodoc:
    include Singleton
  end
end
