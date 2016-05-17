require 'optparse'

class Options
  attr_accessor :create_new, :filename

  def parse!
    self.filename = ARGV.last
    OptionParser.new do |opts|
      opts.banner = "\nUsage: generate [flags] filename\n"

      opts.on('-c','--create','Creates a new yml file for a book') do
        self.create_new = true
      end

      opts.on('-h','--help','Displays help') do
        puts opts
        exit
      end

      puts opts if ARGV.count == 0
    end.parse!
  end

  def create_new?
    create_new
  end

  def generate?
    !create_new && filename
  end
end
