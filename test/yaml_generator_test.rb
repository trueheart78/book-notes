require_relative 'test_helper'
require 'yaml_generator'

class YamlGeneratorTest < Minitest::Test
  include TestHelper
  include FileSystemTestMixin

  def test_writes_file
    output = capture_output { subject.run }

    assert File.exist? subject.file_path
    assert_match(/File created: #{subject.file_path}/, output)
  end

  def test_error_on_existing_file
    suppress_output { subject.run }

    other_yaml_generator = YamlGenerator.new(sample_filename)
    error_string = capture_output{ other_yaml_generator.run }

    assert_match(/Error: File exists \(#{sample_file_path}\)/, error_string)
  end

  def teardown
    File.unlink(sample_file_path) if File.exist? sample_file_path
  end

  def subject
    YamlGenerator.new(sample_filename)
  end

  def sample_filename
    'sample-xxx-book.yml'
  end

  def sample_file_path
    ['yaml', sample_filename].join '/'
  end
end
