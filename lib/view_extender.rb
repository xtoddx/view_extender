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

  VALID_POSITIONS = [:before, :after, :top, :bottom, :replace]

  #
  # This is how a plugin (or other extension method) will inject
  # into a view.  You pass the point to hook into, a unique name
  # that can be used to make sure it is not duplicated and you are able to
  # delete it, and additional args are a block to be rendered.
  #
  # The point to be hooked into (the first argument) will be some view that
  # has a point like:
  #     <% extension_point 'named_point' do %>
  #       This is the default content of the point.
  #     <% end %>
  #
  # You can provide a string to output:
  #   ViewExtender.register('named_point', :top, 'my_key', "String to display")
  #
  # You could also (and most likely) pass argument to render:
  #   ViewExtender.register('named_point', :bottom, 'my_key', :partial => 'my_partial')
  #
  # Additional, you can pass a block that will return a valid third argument,
  # which will be evaluated each time (useful to watch for config changes):
  #   ViewExtender.register('named_point', :replace, 'my_key') do 
  #     Config.show_foo? ? '' : {:partial => 'foo' }
  #   end
  #
  # my_callback = lambda{ Config.show_foo? ? '' : {:partial => 'foo' } }
  # ViewExtender.register('named_point', :before, my_callback)
  #
  # Returns a RenderNode object
  #
  def self.register point, position, key, *render_args, &blk
    # add it to the specified point
    if old = find_render_node_at_point(point, key)
      old.remove
    end
    _registry.at(point).positioned(position).add(key, render_args, &blk)
  end

  #
  # If an extension point is no longer needed, it can be removed.
  # Call with the same point / key arguments it was added with.
  #
  #   ViewExtender.register '/ext/point', :after, 'my_key'
  #   ViewExtender.unregister '/ext/point', 'my_key'
  #
  # Or call with the RenderNode returned by register
  #
  #   my_node = ViewExtender.register '/ext/point', :after, 'my_key'
  #   ViewExtener.unregister my_node
  #
  def self.unregister point, key=nil
    point = find_render_node_at_point(point, key) unless point.is_a?(RenderNode)
    return nil unless point
    point.remove
    _registry.trim!
    true
  end

  #
  # In your view files, call this anywhere the veiw could be extended.
  # The argument 'point' is whatever you would like to name this point,
  # it will be used as the first argument in ViewExtender.register.
  #
  # In your view:
  #   <% extension_point 'index:things_list' do %>
  #     some default content
  #   <% end %>
  #
  # In a plugin or anywhere else you'd like to add an extension:
  #   ViewExtender.register('index:things_list', :top, '<h3>Your List</h3>')
  #
  def extension_point point, &blk

    # Testing HACK: integrate more with rails / erb to get rid of
    # output() and @collected_output, always concat instead of output()
    oco = @collected_output
    @collected_output = ''

    reg = ViewExtender.send(:_registry)

    unless reg[point]
      if block_given?
        # blocks to extension_point should only be run, not output
        # because haml / erb should be handling the output
        output(capture(&blk))
      end
    else
      render_at(reg[point][:before])
      unless render_at(reg[point][:replace])
        render_at(reg[point][:top])

        # a block that gets registered should return something outputable
        if block_given?
          output(capture(&blk))
        end

        render_at(reg[point][:bottom])
      end
      render_at(reg[point][:after])
    end

    nco = @collected_output
    @collected_output = oco

    nco
  end

  private

  def self._registry
    @registry ||= Registry.new
  end

  def self.find_render_node_at_point(point, key)
    return nil unless _registry[point]
    _registry[point].values.flatten.detect{|x| x.key == key}
  end

  def render_at(node_list)
    return unless node_list
    node_list.inject(false) do |rv,n|
      args = n.callback ? [n.callback.call].compact : n.render_args
      if args.length == 1 and args.first.is_a?(String)
        output args.first
      elsif !args.empty?
        output render(*args)
      end
      !args.empty? || rv
    end
  end

  def output str
    if respond_to?(:concat)
      concat(str)
    else
      @collected_output << str
    end
  end

  class Registry < Hash # :nodoc:
    # At the given point, return a sub-registry, create if necessary.
    def at point
      self[point] ||= Registry.new
    end

    # Used for positioning, just look up the next layer
    def positioned where
      self[where] ||= RenderNodeList.new
    end

    def trim!
      keys.each do |k|
        self[k].trim! if self[k].respond_to?(:trim!)
        if self[k].empty?
          self.delete(k)
        end
      end
    end
  end

  class RenderNodeList < Array
    def add key, render_args, &blk
      n = RenderNode.new(key, render_args, self, &blk)
      self << n
      n
    end
  end

  class RenderNode
    attr_accessor :key, :render_args, :node_list, :callback

    def initialize key, render_args, node_list, &callback
      if !callback and render_args.length == 1 and render_args.first.is_a?(Proc)
        callback = render_args.shift
      end
      self.key = key
      self.render_args = render_args
      self.node_list = node_list
      self.callback = callback
    end

    def remove
      node_list.delete(self)
    end

  end

end
