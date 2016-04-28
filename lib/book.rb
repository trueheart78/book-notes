require 'yaml'

class Book
  def initialize(yaml_file)
    @yaml_file = yaml_file
  end

  def directory
    filecase title
  end

  def chapter_list
    @chapters ||= chapters.map.with_index { |v, i| chapter_hash(v, i+1) }
  end

  def image?
    !image.empty?
  end

  def image_file
    "#{directory}-cover.#{image_ext}"
  end

  def to_s
    "'#{title}' by #{author} :: #{chapters.size} chapters"
  end

  def method_missing(method_name, *arguments, &block)
    if attr_list.include?(method_name)
      yaml_data.send(:[], method_name)
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    attr_list.include?(method_name) || super
  end

  private

  def chapter_hash(name, num)
    num = pad_chapter(num)
    {
      num: num,
      name: name,
      path: "ch#{num}-#{filecase(name)}.md"
    }
  end

  def pad_chapter(num)
    return "0#{num}" if num < 10 && chapters.size >= 10
    num.to_s
  end

  def filecase(string)
    string.downcase.gsub(/[^0-9a-z.\-]/, '-')
  end

  def yaml_file
    @yaml_file
  end

  def yaml_data
    @yaml_data ||= YAML.load_file(yaml_file)
  end

  def attr_list
    [:title, :purchase, :author, :homepage, :image, :image_ext, :chapters]
  end
end
