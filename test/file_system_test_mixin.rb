module FileSystemTestMixin
  def test_responds_to_errors
    assert subject.respond_to? :errors
  end

  def test_respond_to_file
    assert subject.respond_to? :file
  end

  def test_respond_to_validate
    assert subject.respond_to? :validate
  end

  def test_respond_to_validate_bang
    assert subject.respond_to? :validate!
  end

  def test_respond_to_file_path
    assert subject.respond_to? :file_path
  end
end
