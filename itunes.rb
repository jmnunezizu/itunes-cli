#!/usr/bin/ruby
require 'getoptlong'
require 'find'
require 'rubygems'
require 'appscript'
include Appscript
require 'tunes'
require 'rainbow' if Gem.available?('rainbow')
require 'Benchmark'

version = "0.1"

$itunes = Appscript.app("iTunes.app", Tunes)
$itunes.run if !$itunes.is_running?

def printusage(error_code)
  print "itunescli -- iTunes Command Line Interface\n"
  print "Usage: itunescli <option>\n"
  print "-a, --add <directory>    adds M4A files in the directory to iTunes\n"
  print "-h, --help               display this help and exit\n"
  print "-v, --version            output version information and exit\n"
  print "\n"
  print "Examples: \n"
  print "itunescli --add /path/to/songs\n"
  exit(error_code)
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

if ARGV.empty?
  printusage(1)
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
              add_to_itunes(f)
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
        printusage(0)

      when "--version"
        print "itunescli ", version, "\n"
        exit(0)
      else
        printusage(1)
    end
  end

rescue
  print "An error occurred: ",$!, "\n"
  printusage(1)
end
    
