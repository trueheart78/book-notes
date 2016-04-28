require 'fileutils'

class NotesGenerator
  def initialize(book)
    @book = book
  end

  def run
    create_directory
    download_image
    write_readme
    write_chapters
    inform_user
  end

  private

  def rollback
    exit 1
  end

  def inform_user
    puts [
      spacer,
      '',
      'Please add the following to the root README.md file:',
      '',
      "1. [#{book.title}](#{readme_path})",
      '',
      spacer,
      '',
      'Book notes generated successfully.'
    ].join "\n"
  end

  def spacer
    '*' * 70
  end

  def create_directory
    FileUtils::mkdir book.directory
  end

  def write_readme
    File.open(readme_path, 'wb') do |file|
      file.write book.to_md
    end
  end

  def readme_path
    [ book.directory, 'README.md' ].join '/'
  end

  def write_chapters
    book.chapter_list.each do |chapter|
      File.open([book.directory,chapter.file].join('/'), 'wb') do |file|
        file.write chapter.to_md
      end
    end
  end

  def download_image
    @image_saved ||= system("wget -O #{book.directory}/#{book.image_file} #{book.image}")
  end

  def image_saved?
    download_image
  end

  def book
    @book
  end
end
