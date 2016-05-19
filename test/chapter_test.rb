require_relative 'test_helper'
require 'chapter'
require 'ostruct'

class ChapterTest < Minitest::Test
  include TestHelper

  def subject
    @subject ||= Chapter.new(mock_chapter.num, mock_chapter.name, zero_based: true)
  end

  def test_to_s
    output = capture_output { print subject }
    assert_equal(mock_chapter.string, output)
  end

  def test_file
    assert_equal(mock_chapter.file, subject.file)
  end

  def test_readme_md
    assert_equal(mock_chapter.readme, subject.readme_md)
  end

  def test_to_md
    assert_match(/\[&lt;&lt; Back to the README\]\(README.md\)/, subject.to_md)
    assert_match(/#{mock_chapter.proper_name}/, subject.to_md)
    assert_match(/\*Notes forthcoming\*/, subject.to_md)
  end

  def mock_chapter
    @mock_chapter ||= OpenStruct.new.tap do |c|
      c.name = 'The Chapter of Nine'
      c.filename = 'the-chapter-of-nine'
      c.num = 8
      c.num_str = '09'
      c.file = "ch#{c.num_str}-#{c.filename}.md"
      c.proper_name = "Chapter #{c.num_str.to_i}. #{c.name}"
      c.readme = "[#{c.proper_name}](#{c.file})"
      c.string = "#{c.num_str}. #{c.name} - #{c.file}"
    end
  end
end
