#!/usr/bin/ruby
require 'getoptlong'
require 'find'
require 'rubygems'
require 'appscript'
include Appscript
require 'tunes'
require 'rainbow' if Gem.available?('rainbow')
require 'Benchmark'

$itunes = Appscript.app("iTunes.app", Tunes)
$itunes.run if !$itunes.is_running?

class ITunesCli

  @@version = "0.1"

  def self.version
    @@version
  end

  def help
    puts "itunescli -- iTunes Command Line Interface"
    puts "Usage: itunescli <option>"
    puts "-a, --add <directory>    adds M4A files in the directory to iTunes"
    puts "-h, --help               display this help and exit"
    puts "-v, --version            output version information and exit"
    puts ""
    puts "Examples:"
    puts "itunescli --add /path/to/songs"
  end

  def version
    print "itunescli ", @@version, "\n"
    exit(0)
  end

  def add_to_itunes(file)
    print File.basename(file).ljust(74, ".")
    result = $itunes.add(MacTypes::Alias.path(file))
    if result != nil
      print "[ "; print "OK".color(:green); puts " ]"
    else
      print "[ "; print "ERROR".color(:red); puts " ]"
    end
  end

end

# main
itunescli = ITunesCli.new

if ARGV.empty?
  itunescli.help
end

opts = GetoptLong.new(
  [ "--add",     "-a", GetoptLong::REQUIRED_ARGUMENT ],
  [ "--help",    "-h", GetoptLong::NO_ARGUMENT ],
  [ "--version", "-v", GetoptLong::NO_ARGUMENT]
)

begin
  opts.each do |opt, arg|
    case opt
      when "--add"
        directory = arg
        num_tunes = 0
        previous_dir = nil
        time = Benchmark.realtime do
          Find.find(directory) do |f|
            if f.match(/\.m4a|.mp3\Z/)
              num_tunes = num_tunes.next
              current_dir = File.dirname(f)
              if current_dir != previous_dir
                previous_dir = current_dir
                print "[ "; print current_dir.color(:cyan); print " ]\n";
              end
              itunescli.add_to_itunes(f)
            end
          end
        end
        
        time_string = (time * 100).round() / 100.0
        puts
        puts "".ljust(80, "-")
        puts "Summary:"
        puts "".ljust(80, "-")
        puts "Total time: #{time_string} seconds"
        puts "Files added:  #{num_tunes}"
        puts "".ljust(80, "-")

      when "--help"
        itunescli.help

      when "--version"
        itunescli.version
      else
        itunescli.help
    end
  end

rescue
  print "An error occurred: ",$!, "\n"
end
    
