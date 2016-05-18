$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'minitest/autorun'
require 'file_system_test_mixin'

module TestHelper
  def capture_output
    old_stdout = $stdout
    $stdout = StringIO.new('','w')
    yield
    $stdout.string
  ensure
    $stdout = old_stdout
  end
  alias :suppress_output :capture_output

  def book_path
    fixture_path('book-valid')
  end

  def fixture_path(fixture)
    ['test','fixtures',"#{fixture}.yml"].join '/'
  end
end
