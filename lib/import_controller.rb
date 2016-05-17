class ImportController
  attr_reader :errors, :file

  def initialize(file)
    @errors = []
    @file = file
  end

  def run
    validate!
    prompt_user
    import if user_approved?
  end

  private

  def validate!
    validate_file
    display_errors if errors.any?
  end

  def file_path
    [directory, file].join '/'
  end

  def prompt_user
    puts book.overview
    puts '---------------------'
    puts "Import #{book}? (y/n)"
    @user_input = STDIN.gets.chomp.downcase[0] until ['y','n'].include? @user_input
  end

  def user_approved?
    @user_input == 'y'
  end

  def import
    generator = NotesGenerator.new book
    generator.run
  end

  def book
    @book ||= Book.new file_path
  end

  def display_errors
    errors.each do |e|
      puts "Error: #{e[:message]}"
    end
    exit 1
  end

  def validate_file
    @errors << { message: 'No file passed' } if file.empty?
    @errors << { message: "File not found (#{file_path})" } unless File.exist? file_path
    @errors << { message: "Directory exists (#{book.directory}/)" } if File.exist? book.directory
  end

  def directory
    'book_data'
  end
end
