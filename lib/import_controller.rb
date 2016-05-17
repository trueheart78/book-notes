require_relative 'file_system'

class ImportController < FileSystem

  def run
    validate
    prompt_user if valid?
    import if valid? && user_approved?
  end

  private

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

  def validate_file
    @errors << { message: 'No file passed' } if file.empty?
    @errors << { message: "File not found (#{file_path})" } unless File.exist? file_path
    @errors << { message: "Directory exists (#{book.directory}/)" } if File.exist? book.directory
  end
end
