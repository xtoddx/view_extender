require 'rubygems'
require 'test/spec'
require 'mocha'
require 'action_view'

require File.join(File.dirname(__FILE__), '..', 'lib', 'view_extender')

module ViewExtenderHelper
  def erb_test str
    "^^#{str}^^"
  end
end

context 'A class including the ViewExtender module' do

  setup do
    @view = ActionView::Base.new
    class << @view ; include ViewExtender ; include ViewExtenderHelper ; end
  end

  context 'when extension_point has no block' do
    context 'When extended with a string' do
      setup do
        ViewExtender.register('test', :top, 'my_key', 'A String')
      end

      teardown do
        ViewExtender.unregister('test', 'my_key')
      end

      it 'should show the string in the output' do
        assert_equal 'A String', @view.render(:inline => "<% extension_point('test') %>")
      end

      it 'should be able to unregister the extension' do
        ViewExtender.unregister('test', 'my_key')
        assert_equal '', @view.render(:inline => "<% extension_point('test') %>")
      end
    end

    context 'When extended with a hash' do
      setup do
        @hash = {:text => 'custom text'}
        ViewExtender.register('test', :top, 'my_key', @hash)
      end

      teardown do
        ViewExtender.unregister('test', 'my_key')
      end

      it 'should call `render` with the given hash' do
        assert_equal 'custom text', @view.render(:inline => "<% extension_point('test') %>")
      end

      it 'should be able to unregister the extension' do
        ViewExtender.unregister('test', 'my_key')
        assert_equal '', @view.render(:inline => "<% extension_point('test') %>")
      end
    end

    context 'When extened with a proc that returns a string' do
      setup do
        @proc = lambda{ 'STRING' }
        ViewExtender.register('test', :top, 'my_key', @proc)
      end

      teardown do
        ViewExtender.unregister('test', 'my_key')
      end

      it 'should output the given string' do
        assert_equal 'STRING', @view.render(:inline => "<% extension_point('test') %>")
      end

      it 'should be able to unregister the extension' do
        ViewExtender.unregister('test', 'my_key')
        assert_equal '', @view.render(:inline => "<% extension_point('test') %>")
      end
    end

    context 'When extened with a proc that returns a hash' do
      setup do
        @hash = {:text => 'FOO'}
        @proc = lambda{ @hash }
        ViewExtender.register('test', :top, 'my_key', @proc)
      end

      teardown do
        ViewExtender.unregister('test', 'my_key')
      end

      it 'should call `render` with the given hash' do
        assert_equal 'FOO', @view.render(:inline => "<% extension_point('test') %>")
      end

      it 'should be able to unregister the extension' do
        ViewExtender.unregister('test', 'my_key')
        assert_equal '', @view.render(:inline => "<% extension_point('test') %>")
      end
    end

    context 'When extended with a block that returns a string' do
      setup do
        @del_obj = ViewExtender.register('test', :top, 'my_key') do
                     'OUTPUT'
                   end
      end

      teardown do
        ViewExtender.unregister('test', 'my_key')
      end

      it 'should output the given string' do
        assert_equal 'OUTPUT', @view.render(:inline => "<% extension_point('test') %>")
      end

      it 'should be able to unregiser via the object returned from register' do
        ViewExtender.unregister(@del_obj)
        assert_equal '', @view.render(:inline => "<% extension_point('test') %>")
      end
    end

    context 'When extended with a block that returns a hash' do
      setup do
        @hash = {:text => 'FOO'}
        @del_obj = ViewExtender.register('test', :top, 'my_key') do
                     @hash
                   end
      end

      teardown do
        ViewExtender.unregister('test', 'my_key')
      end

      it 'should call `render` with the given hash' do
        assert_equal 'FOO', @view.render(:inline => "<% extension_point('test') %>")
      end

      it 'should be able to unregister the extension' do
        ViewExtender.unregister(@del_obj)
        assert_equal '', @view.render(:inline => "<% extension_point('test') %>")
      end
    end
  end

  context 'when extension_point provides a default block (String)' do
    context 'When extended with a string' do
      setup do
        ViewExtender.register('test', :top, 'my_key', 'A String')
      end

      teardown do
        ViewExtender.unregister('test', 'my_key')
      end

      it 'should show the string in the output' do
        assert_equal 'A String DEF', @view.render(:inline => "<% extension_point('test') do %> DEF<% end %>")
      end

      it 'should be able to unregister the extension' do
        ViewExtender.unregister('test', 'my_key')
        assert_equal ' DEF', @view.render(:inline => "<% extension_point('test') do %> DEF<% end %>")
      end
    end

    context 'When extended with a hash' do
      setup do
        @hash = {:text => 'HASHOUT'}
        ViewExtender.register('test', :top, 'my_key', @hash)
      end

      teardown do
        ViewExtender.unregister('test', 'my_key')
      end

      it 'should call `render` with the given hash' do
        assert_equal 'HASHOUT DEF', @view.render(:inline => "<% extension_point('test') do %> DEF<% end %>")
      end

      it 'should be able to unregister the extension' do
        ViewExtender.unregister('test', 'my_key')
        assert_equal ' DEF', @view.render(:inline => "<% extension_point('test') do %> DEF<% end %>")
      end
    end

    context 'When extened with a proc that returns a string' do
      setup do
        @proc = lambda{ 'STRING' }
        ViewExtender.register('test', :top, 'my_key', @proc)
      end

      teardown do
        ViewExtender.unregister('test', 'my_key')
      end

      it 'should output the given string' do
        assert_equal 'STRING DEF', @view.render(:inline => "<% extension_point('test') do %> DEF<% end %>")
      end

      it 'should be able to unregister the extension' do
        ViewExtender.unregister('test', 'my_key')
        assert_equal ' DEF', @view.render(:inline => "<% extension_point('test') do %> DEF<% end %>")
      end
    end

    context 'When extened with a proc that returns a hash' do
      setup do
        @hash = {:text => 'FOO'}
        @proc = lambda{ @hash }
        ViewExtender.register('test', :top, 'my_key', @proc)
      end

      teardown do
        ViewExtender.unregister('test', 'my_key')
      end

      it 'should call `render` with the given hash' do
        assert_equal 'FOO DEF', @view.render(:inline => "<% extension_point('test') do %> DEF<% end %>")
      end

      it 'should be able to unregister the extension' do
        ViewExtender.unregister('test', 'my_key')
        assert_equal ' DEF', @view.render(:inline => "<% extension_point('test') do %> DEF<% end %>")
      end
    end

    context 'When extended with a block that returns a string' do
      setup do
        @del_obj = ViewExtender.register('test', :top, 'my_key') do
                     'OUTPUT'
                   end
      end

      teardown do
        ViewExtender.unregister('test', 'my_key')
      end

      it 'should output the given string' do
        assert_equal 'OUTPUT DEF', @view.render(:inline => "<% extension_point('test') do %> DEF<% end %>")
      end

      it 'should be able to unregiser via the object returned from register' do
        ViewExtender.unregister(@del_obj)
        assert_equal ' DEF', @view.render(:inline => "<% extension_point('test') do %> DEF<% end %>")
      end
    end

    context 'When extended with a block that returns a hash' do
      setup do
        @hash = {:text => 'FOO'}
        @del_obj = ViewExtender.register('test', :top, 'my_key') do
                     @hash
                   end
      end

      teardown do
        ViewExtender.unregister('test', 'my_key')
      end

      it 'should call `render` with the given hash' do
        assert_equal 'FOO DEF', @view.render(:inline => "<% extension_point('test') do %> DEF<% end %>")
      end

      it 'should be able to unregister the extension' do
        ViewExtender.unregister(@del_obj)
        assert_equal ' DEF', @view.render(:inline => "<% extension_point('test') do %> DEF<% end %>")
      end
    end
  end

  context 'When inserting at different positions' do

    teardown do
      ViewExtender.unregister('test', 'my_key')
    end

    it 'should prepend text with :before' do
      ViewExtender.register('test', :before, 'my_key', 'STR')
      assert_equal 'STR DEF', @view.render(:inline => "<% extension_point('test') do %> DEF<% end %>")
    end

    it 'should prepend text with :top' do
      ViewExtender.register('test', :top, 'my_key', 'STR')
      assert_equal 'STR DEF', @view.render(:inline => "<% extension_point('test') do %> DEF<% end %>")
    end

    it 'should have :before before :top' do
      ViewExtender.register('test', :before, 'my_key', 'MY')
      ViewExtender.register('test', :top, 'my_key2', 'STR')
      assert_equal 'MYSTR DEF', @view.render(:inline => "<% extension_point('test') do %> DEF<% end %>")
      ViewExtender.unregister('test', 'my_key2')
    end

    it 'should replace text with :replace' do
      ViewExtender.register('test', :replace, 'my_key', 'STR')
      assert_equal 'STR', @view.render(:inline => "<% extension_point('test') do %> DEF<% end %>")
    end

    it 'should not replace text with :replace when block returns nil' do
      ViewExtender.register('test', :replace, 'my_key') { nil }
      assert_equal ' DEF', @view.render(:inline => "<% extension_point('test') do %> DEF<% end %>")
    end

    it 'should append text with :bottom' do
      ViewExtender.register('test', :bottom, 'my_key', 'LISH')
      assert_equal ' DEFLISH', @view.render(:inline => "<% extension_point('test') do %> DEF<% end %>")
    end

    it 'should append text with :after' do
      ViewExtender.register('test', :after, 'my_key', 'LISH')
      assert_equal ' DEFLISH', @view.render(:inline => "<% extension_point('test') do %> DEF<% end %>")
    end

    it 'should have :after after :bottom' do
      ViewExtender.register('test', :after, 'my_key', 'MAN')
      ViewExtender.register('test', :bottom, 'my_key2', 'LISH')
      assert_equal ' DEFLISHMAN', @view.render(:inline => "<% extension_point('test') do %> DEF<% end %>")
      ViewExtender.unregister('test', 'my_key2')
    end

    it 'should yield appropriately when nested' do
      ViewExtender.register('test', :top, 'my_key', 'MAN')
      ViewExtender.register('test2', :top, 'my_key2', 'LISH')
      assert_equal 'MAN LEADIN LISH LEADOUT ', @view.render(:inline => "<% extension_point('test') do %> LEADIN <% extension_point('test2') %> LEADOUT <% end %>")
      ViewExtender.unregister('test', 'my_key2')
    end
  end

  context 'when more than one point at same position' do
    it 'should show them in the order they were added' do
      ViewExtender.register('test', :bottom, 'my_key2', 'LISH')
      ViewExtender.register('test', :bottom, 'my_key', 'MAN')
      assert_equal ' DEFLISHMAN', @view.render(:inline => "<% extension_point('test') do %> DEF<% end %>")
      ViewExtender.unregister('test', 'my_key')
      ViewExtender.unregister('test', 'my_key2')
    end

    it 'should overwrite anything at the same point with the same key' do
      ViewExtender.register('test', :bottom, 'my_key', 'MAN')
      ViewExtender.register('test', :bottom, 'my_key', 'LISH')
      assert_equal ' DEFLISH', @view.render(:inline => "<% extension_point('test') do %> DEF<% end %>")
      ViewExtender.unregister('test', 'my_key')
    end
  end

  context 'when extension_point provides a default block (Template)' do
    context 'When extended with a string' do
      setup do
        ViewExtender.register('test', :top, 'my_key', 'A String ')
      end

      teardown do
        ViewExtender.unregister('test', 'my_key')
      end

      it 'should show the string in the output' do
        assert_equal 'A String ^^foo^^', @view.render(:inline => '<% extension_point("test") do %><%= erb_test("foo") %><% end %>')
      end

      it 'should be able to unregister the extension' do
        ViewExtender.unregister('test', 'my_key')
        assert_equal '^^foo^^', @view.render(:inline => '<% extension_point("test") do %><%= erb_test("foo") %><% end %>')
      end
    end

    context 'When extended with a hash' do
      setup do
        @hash = {:text => 'HASHOUT'}
        ViewExtender.register('test', :top, 'my_key', @hash)
      end

      teardown do
        ViewExtender.unregister('test', 'my_key')
      end

      it 'should call `render` with the given hash' do
        assert_equal 'HASHOUT^^foo^^', @view.render(:inline => '<% extension_point("test") do %><%= erb_test("foo") %><% end %>')
      end

      it 'should be able to unregister the extension' do
        ViewExtender.unregister('test', 'my_key')
        assert_equal '^^foo^^', @view.render(:inline => '<% extension_point("test") do %><%= erb_test("foo") %><% end %>')
      end
    end

    context 'When extened with a proc that returns a string' do
      setup do
        @proc = lambda{ 'STRING' }
        ViewExtender.register('test', :top, 'my_key', @proc)
      end

      teardown do
        ViewExtender.unregister('test', 'my_key')
      end

      it 'should output the given string' do
        assert_equal 'STRING^^foo^^', @view.render(:inline => '<% extension_point("test") do %><%= erb_test("foo") %><% end %>')
      end

      it 'should be able to unregister the extension' do
        ViewExtender.unregister('test', 'my_key')
        assert_equal '^^foo^^', @view.render(:inline => '<% extension_point("test") do %><%= erb_test("foo") %><% end %>')
      end
    end

    context 'When extened with a proc that returns a hash' do
      setup do
        @hash = {:text => 'FOO'}
        @proc = lambda{ @hash }
        ViewExtender.register('test', :top, 'my_key', @proc)
      end

      teardown do
        ViewExtender.unregister('test', 'my_key')
      end

      it 'should call `render` with the given hash' do
        assert_equal 'FOO^^foo^^', @view.render(:inline => '<% extension_point("test") do %><%= erb_test("foo") %><% end %>')
      end

      it 'should be able to unregister the extension' do
        ViewExtender.unregister('test', 'my_key')
        assert_equal '^^foo^^', @view.render(:inline => '<% extension_point("test") do %><%= erb_test("foo") %><% end %>')
      end
    end

    context 'When extended with a block that returns a string' do
      setup do
        @del_obj = ViewExtender.register('test', :top, 'my_key') do
                     'OUTPUT'
                   end
      end

      teardown do
        ViewExtender.unregister('test', 'my_key')
      end

      it 'should output the given string' do
        assert_equal 'OUTPUT^^foo^^', @view.render(:inline => '<% extension_point("test") do %><%= erb_test("foo") %><% end %>')
      end

      it 'should be able to unregiser via the object returned from register' do
        ViewExtender.unregister(@del_obj)
        assert_equal '^^foo^^', @view.render(:inline => '<% extension_point("test") do %><%= erb_test("foo") %><% end %>')
      end
    end

    context 'When extended with a block that returns a hash' do
      setup do
        @hash = {:text => 'FOO'}
        @del_obj = ViewExtender.register('test', :top, 'my_key') do
                     @hash
                   end
      end

      teardown do
        ViewExtender.unregister('test', 'my_key')
      end

      it 'should call `render` with the given hash' do
        assert_equal 'FOO^^foo^^', @view.render(:inline => '<% extension_point("test") do %><%= erb_test("foo") %><% end %>')
      end

      it 'should be able to unregister the extension' do
        ViewExtender.unregister(@del_obj)
        assert_equal '^^foo^^', @view.render(:inline => '<% extension_point("test") do %><%= erb_test("foo") %><% end %>')
      end
    end
  end

end
