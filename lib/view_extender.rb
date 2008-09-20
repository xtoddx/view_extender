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

#
# This module gets included into ActionView::Base in init.rb, making
# the instance method extension_point available in your views.  See
# README.markdown for an example of how to add to a view.
#
module ViewExtender

  #
  # This is how a plugin (or other extension method) will inject
  # into a view.  You pass the point to hook into, a unique name
  # that can be used to make sure it is not duplicated and you are able to
  # delete it, and additional args are a block to be rendered.
  #
  # The point to be hooked into (the first argument) will be some view that
  # has a point like:
  #     <%= extension_point 'named_point' %>
  #
  # You can provide a string to output:
  #   ViewExtender.register('named_point', 'my_key', "String to display")
  #
  # You could also (and most likely) pass argument to render:
  #   ViewExtender.register('named_point', 'my_key', :partial => 'my_partial')
  #
  # Additional, you can pass a block that will return a valid third argument,
  # which will be evaluated each time (useful to watch for config changes):
  #   ViewExtender.register('named_point', 'my_key') do 
  #     Config.show_foo? ? '' : {:partial => 'foo' }
  #   end
  #
  # my_callback = lambda{ Config.show_foo? ? '' : {:partial => 'foo' } }
  # ViewExtender.register('named_point', my_callback)
  #
  def self.register point, key, *render_args, &blk
    # map the block onto the args as a proc
    render_args.push(blk) if blk

    # add it to the specified point
    _registry.at(point).add(key, render_args)

    # return the unique key that can be used to unregister it
    key
  end

  #
  # If an extension point is no longer needed, it can be removed.
  # Call with the same point / key arguments it was added with.
  #
  #   ViewExtender.register '/ext/point', 'my_key'
  #   ViewExtender.unregister '/ext/point', 'my_key'
  #
  # returns the args passed in
  def self.unregister point, key
    return nil unless _registry[point] and _registry[point][key]
    rv = _registry[point].delete(key)
    if _registry[point].empty?
      _registry.delete(point)
    end
    rv
  end

  #
  # In your view files, call this anywhere the veiw could be extended.
  # The argument 'point' is whatever you would like to name this point,
  # it will be used as the first argument in ViewExtender.register.
  #
  # In your view:
  #   <%= extension_point 'index:before_list' %>
  #
  # In a plugin or anywhere else you'd like to add an extension:
  #   ViewExtender.register('index:before_list', '<h3>Your List</h3>')
  #
  def extension_point point
    reg = ViewExtender.send(:_registry)
    return '' unless reg[point]
    reg[point].values.collect do |render_args|

      # if we took in a block, call with its output
      if render_args.first.is_a?(Proc)
        render_args = [render_args.first.call]
      end

      # collect gets the result of this condition, which is either just
      # a string that was passed in, or the results of a call to render
      if render_args.length == 1 and render_args.first.is_a?(String)
        render_args.first
      else
        render *render_args
      end

    end.join("\n")
  end

  private

  def self._registry
    @registry ||= Registry.new
  end

  class Registry < Hash # :nodoc:

    # At the given point, return a sub-registry, create if necessary.
    def at point
      self[point] ||= Registry.new
    end

    # make an alias so things are more readable
    alias :add :[]=
  end
end
