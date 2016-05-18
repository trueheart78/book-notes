class FileSystem
  attr_reader :errors, :file

  def initialize(file)
    @errors = []
    @file = file
  end

  def validate
    validate_file
    display_errors if errors.any?
  end

  def validate!
    validate
    exit 1 if errors.any?
  end

  def file_path
    [directory, file].join '/'
  end

  private

  def valid?
    errors.size == 0
  end

  def display_errors
    errors.each do |e|
      puts "Error: #{e[:message]}"
    end
  end

  def validate_file
  end

  def directory
    'book-yaml'
  end
end
