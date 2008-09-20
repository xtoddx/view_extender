require 'rubygems'
require 'test/spec'
require 'mocha'

require File.join(File.dirname(__FILE__), '..', 'lib', 'view_extender')

context 'A class including the ViewExtender module' do

  setup do
    @view = Object.new
    class << @view ; include ViewExtender ; end
  end

  context 'When extended with a string' do
    setup do
      ViewExtender.register('test', 'my_key', 'A String')
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
      ViewExtender.register('test', 'my_key', @hash)
    end

    teardown do
      ViewExtender.unregister('test', 'my_key')
    end

    it 'should call `render` with the given hash' do
      @view.expects(:render).with(@hash)
      @view.extension_point('test')
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
      ViewExtender.register('test', 'my_key', @proc)
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
      ViewExtender.register('test', 'my_key', @proc)
    end

    teardown do
      ViewExtender.unregister('test', 'my_key')
    end

    it 'should call `render` with the given hash' do
      @view.expects(:render).with(@hash)
      @view.extension_point('test')
    end

    it 'should be able to unregister the extension' do
      ViewExtender.unregister('test', 'my_key')
      @view.stubs(:render).returns('EEEK -- I AM A FAILURE')
      assert_equal '', @view.extension_point('test')
    end
  end

  context 'When extended with a block that returns a string' do

    setup do
      @del_obj = ViewExtender.register('test', 'my_key') do
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
      ViewExtender.unregister('test', @del_obj)
      assert_equal '', @view.extension_point('test')
    end
  end

  context 'When extended with a block that returns a hash' do

    setup do
      @hash = {:partial => 'foo'}
      @del_obj = ViewExtender.register('test', 'my_key') do
                   @hash
                 end
    end

    teardown do
      ViewExtender.unregister('test', 'my_key')
    end

    it 'should call `render` with the given hash' do
      @view.expects(:render).with(@hash)
      @view.extension_point('test')
    end

    it 'should be able to unregister the extension' do
      ViewExtender.unregister('test', @del_obj)
      @view.stubs(:render).returns('EEEK -- I AM A FAILURE')
      assert_equal '', @view.extension_point('test')
    end
  end

end
