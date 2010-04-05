View Extender
=============

In your views put

    <% extension_point 'my_extension_point_name' %>

Or

    <% extension_point 'my_extension_point_name' do %>
      <div> DEFAULT CONTENT TO BE ALTERED </div>
    <% end %>

Plugins, etc can then add to this view via:

    # specify a string to put in the output
    ViewExtender.register('my_extension_point', :bottom, 'my_key', "STRING TO OUTPUT")

    # make a call to the render method at the specified point
    ViewExtender.register('my_extension_point', :top, 'my_key', :partial => 'partial_file')

    # dynamically build a render call
    ViewExtender.register('my_extension_point', :replace, 'my_key') do
      :partial => Configuration.feature_x_enabled? ? 'feature_x' : 'no_feature_x'
    end

There can be any number of extensions at a single point.  They will be
displayed in the order they are added. They can be removed via

    ViewExtender.unregister('my_extension_point', 'my_key')

The positions you can extend are :before/:top, :replace, :bottom/:after.  You
can use :replace with a block to either replace it, or if the block returns nil,
do nothing.
