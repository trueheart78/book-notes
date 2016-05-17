require_relative 'file_system'

class YamlGenerator < FileSystem

  def run
    validate
    create if valid?
  end

  private

  def create
    File.open(file_path,'w') do |file|
      file.puts content
    end
    puts "File created: #{file_path}"
  end

  def validate_file
    @errors << { message: 'No file passed' } if file.empty?
    @errors << { message: "File exists (#{file_path})" } if File.exist? file_path
  end

  def content
    <<~YAML
    ---
    :title:
    :purchase:
    :author:
    :homepage:
    :image:
    :image_ext:

    :chapters:
      - chapter
    YAML
  end
end
