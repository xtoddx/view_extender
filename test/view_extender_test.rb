require 'rubygems'
require 'test/spec'
require 'mocha'

require File.join(File.dirname(__FILE__), '..', 'lib', 'view_extender')

context 'A class including the ViewExtender module' do

  setup do
    @view = Object.new
    class << @view ; include ViewExtender ; end
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
        assert_equal 'A String', @view.extension_point('test')
      end

      it 'should be able to unregister the extension' do
        ViewExtender.unregister('test', 'my_key')
        assert_equal '', @view.extension_point('test')
      end
    end

    context 'When extended with a hash' do
      setup do
        @hash = {:partial => 'my_partial'}
        ViewExtender.register('test', :top, 'my_key', @hash)
      end

      teardown do
        ViewExtender.unregister('test', 'my_key')
      end

      it 'should call `render` with the given hash' do
        @view.expects(:render).with(@hash).returns('HASHOUT')
        assert_equal 'HASHOUT', @view.extension_point('test')
      end

      it 'should be able to unregister the extension' do
        ViewExtender.unregister('test', 'my_key')

        # add a stub that will guarantee failure if called
        @view.stubs(:render).returns('EEEK -- I AM A FAILURE')

        assert_equal '', @view.extension_point('test')
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
        assert_equal 'STRING', @view.extension_point('test')
      end

      it 'should be able to unregister the extension' do
        ViewExtender.unregister('test', 'my_key')
        assert_equal '', @view.extension_point('test')
      end
    end

    context 'When extened with a proc that returns a hash' do
      setup do
        @hash = {:partial => 'foo'}
        @proc = lambda{ @hash }
        ViewExtender.register('test', :top, 'my_key', @proc)
      end

      teardown do
        ViewExtender.unregister('test', 'my_key')
      end

      it 'should call `render` with the given hash' do
        @view.expects(:render).with(@hash).returns("FOO")
        assert_equal 'FOO', @view.extension_point('test')
      end

      it 'should be able to unregister the extension' do
        ViewExtender.unregister('test', 'my_key')
        @view.stubs(:render).returns('EEEK -- I AM A FAILURE')
        assert_equal '', @view.extension_point('test')
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
        assert_equal 'OUTPUT', @view.extension_point('test')
      end

      it 'should be able to unregiser via the object returned from register' do
        ViewExtender.unregister(@del_obj)
        assert_equal '', @view.extension_point('test')
      end
    end

    context 'When extended with a block that returns a hash' do
      setup do
        @hash = {:partial => 'foo'}
        @del_obj = ViewExtender.register('test', :top, 'my_key') do
                     @hash
                   end
      end

      teardown do
        ViewExtender.unregister('test', 'my_key')
      end

      it 'should call `render` with the given hash' do
        @view.expects(:render).with(@hash).returns('FOO')
        assert_equal 'FOO', @view.extension_point('test')
      end

      it 'should be able to unregister the extension' do
        ViewExtender.unregister(@del_obj)
        @view.stubs(:render).returns('EEEK -- I AM A FAILURE')
        assert_equal '', @view.extension_point('test')
      end
    end
  end

  context 'when extension_point provides a default block' do
    context 'When extended with a string' do
      setup do
        ViewExtender.register('test', :top, 'my_key', 'A String')
      end

      teardown do
        ViewExtender.unregister('test', 'my_key')
      end

      it 'should show the string in the output' do
        assert_equal 'A String DEF', @view.extension_point('test'){ ' DEF' }
      end

      it 'should be able to unregister the extension' do
        ViewExtender.unregister('test', 'my_key')
        assert_equal ' DEF', @view.extension_point('test'){ ' DEF' }
      end
    end

    context 'When extended with a hash' do
      setup do
        @hash = {:partial => 'my_partial'}
        ViewExtender.register('test', :top, 'my_key', @hash)
      end

      teardown do
        ViewExtender.unregister('test', 'my_key')
      end

      it 'should call `render` with the given hash' do
        @view.expects(:render).with(@hash).returns('HASHOUT')
        assert_equal 'HASHOUT OP', @view.extension_point('test'){' OP'}
      end

      it 'should be able to unregister the extension' do
        ViewExtender.unregister('test', 'my_key')

        # add a stub that will guarantee failure if called
        @view.stubs(:render).returns('EEEK -- I AM A FAILURE')

        assert_equal ' OP', @view.extension_point('test'){' OP'}
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
        assert_equal 'STRING OG', @view.extension_point('test'){' OG'}
      end

      it 'should be able to unregister the extension' do
        ViewExtender.unregister('test', 'my_key')
        assert_equal ' OG', @view.extension_point('test'){' OG'}
      end
    end

    context 'When extened with a proc that returns a hash' do
      setup do
        @hash = {:partial => 'foo'}
        @proc = lambda{ @hash }
        ViewExtender.register('test', :top, 'my_key', @proc)
      end

      teardown do
        ViewExtender.unregister('test', 'my_key')
      end

      it 'should call `render` with the given hash' do
        @view.expects(:render).with(@hash).returns('FOO')
        assert_equal 'FOOBAR', @view.extension_point('test'){'BAR'}
      end

      it 'should be able to unregister the extension' do
        ViewExtender.unregister('test', 'my_key')
        @view.stubs(:render).returns('EEEK -- I AM A FAILURE')
        assert_equal 'BAR', @view.extension_point('test'){'BAR'}
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
        assert_equal 'OUTPUTBAR', @view.extension_point('test'){'BAR'}
      end

      it 'should be able to unregiser via the object returned from register' do
        ViewExtender.unregister(@del_obj)
        assert_equal 'BAR', @view.extension_point('test'){'BAR'}
      end
    end

    context 'When extended with a block that returns a hash' do
      setup do
        @hash = {:partial => 'foo'}
        @del_obj = ViewExtender.register('test', :top, 'my_key') do
                     @hash
                   end
      end

      teardown do
        ViewExtender.unregister('test', 'my_key')
      end

      it 'should call `render` with the given hash' do
        @view.expects(:render).with(@hash).returns('FOO')
        assert_equal 'FOOBAR', @view.extension_point('test'){'BAR'}
      end

      it 'should be able to unregister the extension' do
        ViewExtender.unregister(@del_obj)
        @view.stubs(:render).returns('EEEK -- I AM A FAILURE')
        assert_equal 'BAR', @view.extension_point('test'){'BAR'}
      end
    end
  end

  context 'When inserting at different positions' do

    teardown do
      ViewExtender.unregister('test', 'my_key')
    end

    it 'should prepend text with :before' do
      ViewExtender.register('test', :before, 'my_key', 'STR')
      assert_equal 'STRING', @view.extension_point('test'){'ING'}
    end

    it 'should prepend text with :top' do
      ViewExtender.register('test', :top, 'my_key', 'STR')
      assert_equal 'STRING', @view.extension_point('test'){'ING'}
    end

    it 'should have :before before :top' do
      ViewExtender.register('test', :before, 'my_key', 'MY')
      ViewExtender.register('test', :top, 'my_key2', 'STR')
      assert_equal 'MYSTRING', @view.extension_point('test'){'ING'}
      ViewExtender.unregister('test', 'my_key2')
    end

    it 'should replace text with :replace' do
      ViewExtender.register('test', :replace, 'my_key', 'STR')
      assert_equal 'STR', @view.extension_point('test'){'ING'}
    end

    it 'should not replace text with :replace when block returns nil' do
      ViewExtender.register('test', :replace, 'my_key') { nil }
      assert_equal 'ING', @view.extension_point('test'){'ING'}
    end

    it 'should append text with :bottom' do
      ViewExtender.register('test', :bottom, 'my_key', 'LISH')
      assert_equal 'INGLISH', @view.extension_point('test'){'ING'}
    end

    it 'should append text with :after' do
      ViewExtender.register('test', :after, 'my_key', 'LISH')
      assert_equal 'INGLISH', @view.extension_point('test'){'ING'}
    end

    it 'should have :after after :bottom' do
      ViewExtender.register('test', :after, 'my_key', 'MAN')
      ViewExtender.register('test', :bottom, 'my_key2', 'LISH')
      assert_equal 'INGLISHMAN', @view.extension_point('test'){'ING'}
      ViewExtender.unregister('test', 'my_key2')
    end

    it 'should yield appropriately when nested' do
      ViewExtender.register('test', :top, 'my_key', 'MAN')
      ViewExtender.register('test2', :top, 'my_key2', 'LISH')
      assert_equal 'MANLEADIN LISH LEADOUT', @view.extension_point('test'){ "LEADIN #{@view.extension_point('test2')} LEADOUT"}
      ViewExtender.unregister('test', 'my_key2')
    end
  end

  context 'when more than one point at same position' do
    it 'should show them in the order they were added' do
      ViewExtender.register('test', :bottom, 'my_key2', 'LISH')
      ViewExtender.register('test', :bottom, 'my_key', 'MAN')
      assert_equal 'INGLISHMAN', @view.extension_point('test'){'ING'}
      ViewExtender.unregister('test', 'my_key')
      ViewExtender.unregister('test', 'my_key2')
    end

    it 'should overwrite anything at the same point with the same key' do
      ViewExtender.register('test', :bottom, 'my_key', 'MAN')
      ViewExtender.register('test', :bottom, 'my_key', 'LISH')
      assert_equal 'INGLISH', @view.extension_point('test'){'ING'}
      ViewExtender.unregister('test', 'my_key')
    end
  end

end
