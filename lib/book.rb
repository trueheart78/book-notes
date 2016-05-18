require 'yaml'

class Book
  def initialize(yaml_file)
    @yaml_file = yaml_file
  end

  def overview
    [
      "- Directory: #{directory}",
      "- Title: #{title}",
      "- Purchase: #{purchase}",
      "- Author: #{author}",
      "- Homepage: #{homepage}",
      "- Image? #{image?} [#{image_ext}]",
      "   #{image}",
      "- Chapters: #{chapters.size}",
    ].concat(chapter_overview).join "\n"
  end

  def chapter_overview
    chapter_list.map { |x| left_pad(x) }
  end

  def directory
    ['book-notes', title.downcase.gsub(/[^0-9a-z.\-]/, '-')].join '/'
  end

  def chapter_list
    @chapters ||= chapters.map.with_index { |name, num| Chapter.new num, name }
  end

  def image?
    return true if image && !image.empty?
    false
  end

  def image_file
    "cover.#{image_ext}"
  end

  def to_md
    [
      '[&lt;&lt; Back to project home](../../README.md)',
      '',
      "# #{title}",
      '',
      "By the #{adjective} [#{author}](#{homepage})",
      '',
      "[Purchase](#{purchase})",
      '',
      'Notes:',
      ''
    ].concat(chapter_md).concat(image_md).join "\n"
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

  def left_pad(string)
    "   #{string}"
  end

  def chapter_md
    chapter_list.map(&:readme_md).map { |chapter| "- #{chapter}" }
  end

  def image_md
    return [ '', "![book cover](#{image_file})" ] if image?
    []
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

  def adjective
    %w{fantastic grand marvelous terrific tremendous wondrous howling rattling}.sample
  end
end
