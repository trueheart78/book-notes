require_relative 'test_helper'
require 'book'
require 'chapter'

class BookTest < Minitest::Test
  include TestHelper

  def subject
    @subject ||= Book.new(book_path)
  end

  def test_image_file
    assert(subject.image?)
    assert_equal('cover.jpg', subject.image_file)
  end

  def test_missing_image_file
    subject_wo_image = Book.new(fixture_path('book-valid-no-image'))
    refute(subject_wo_image.image?)
    refute(subject_wo_image.image)
  end

  def test_directory
    assert_equal('book-notes/an-awesome-book', subject.directory)
  end

  def test_chapter_overview

  end

  def test_chapter_list

  end

  def test_overview
    assert_match(/Directory: #{subject.directory}/, subject.overview)
    assert_match(/Title: #{subject.title}/, subject.overview)
    assert_match(/Purchase: #{subject.purchase}/, subject.overview)
  end

  def test_to_md

  end

  def test_to_s
    assert_equal "'An Awesome Book' by That One Girl :: 4 chapters", subject.to_s
  end

  def test_public_yaml_interface
    assert subject.respond_to?(:title)
  end
end
