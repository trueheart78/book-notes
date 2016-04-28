class NotesGenerator
  def initialize(book)
    @book = book
  end

  def run
    puts '[ process details required ]'
    puts book.to_md
  end

  private

  def download_image
    #`wget -O #{book.directory}/#{book.image_file} #{book.image}`
  end

  def book
    @book
  end
end
