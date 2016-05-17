require_relative 'test_helper'
require 'options'

class OptionsTest < Minitest::Test
  include TestHelper

  def setup
    reset_args
  end

  def test_no_arguments
    options = Options.new

    assert_match help_text_regex, capture_output { options.parse! }
    assert_equal false, options.continue?
  end

  def test_help_argument
    ARGV << '-h'
    options = Options.new

    assert_match help_text_regex, capture_output { options.parse! }
    assert_equal false, options.continue?
  end

  def test_create_argument
    ARGV << '-c'
    ARGV << sample_filename.split('.').first

    options = Options.new
    options.parse!

    assert options.create_new?
    assert_equal sample_filename, options.file
  end

  def test_filename_only
    ARGV << sample_filename
    options = Options.new
    options.parse!

    assert_equal sample_filename, options.file
    assert options.generate?
    assert_nil options.create_new?
  end

  def test_filename_without_extension
    ARGV << sample_filename.split('.').first
    options = Options.new

    assert_empty capture_output { options.parse! }
    assert options.generate?
    assert_equal sample_filename, options.file
  end

  def sample_filename
    'sample.yml'
  end

  def reset_args
    ARGV.pop until ARGV.size == 0
  end

  def help_text_regex
    /Usage: generate \[options\] filename/
  end
end
