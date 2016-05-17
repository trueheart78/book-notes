require 'optparse'

class Options
  attr_accessor :create_new, :filename, :continue

  def initialize
    self.continue = true
  end

  def parse!
    self.filename = ARGV.last
    OptionParser.new do |opts|
      opts.banner = "\nUsage: generate [flags] filename\n"

      opts.on('-c','--create','Creates a new yml file for a book') do
        self.create_new = true
      end

      opts.on('-h','--help','Displays help') do
        self.continue = false
        puts opts
      end

      self.continue = false if ARGV.count == 0 || !self.file?

      puts opts unless self.continue?
    end.parse!
  end

  def create_new?
    create_new
  end

  def generate?
    !create_new? && file?
  end

  def file?
    !self.filename.nil?
  end

  def file
    return "#{filename}.yml" unless filename.downcase[-4..-1] == '.yml'
    filename
  end

  def continue?
    self.continue
  end
end
