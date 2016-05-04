require "option_parser"
require "colorize"

module Log
  module CLI
    def self.run
      type = nil
      project = nil
      search_text = nil
      clear_last_entry = false

      OptionParser.parse! do |parser|
        parser.banner = "Usage: #{$0} [arguments]"
        parser.on("-t TYPE", "--type=TYPE", "The type classification that the log event belongs to. example: work, school etc.") { |t| type = t }
        parser.on("-p PROJECT", "--project=PROJECT", "The project that the log event belongs to. This helps group log events together
                                     which might belong to the same type or which my not belong to a type at all.") { |p| project = p }

        parser.on("-s TEXT", "Case insensitive search of the log file for the given text.") { |s| search_text = s }
        parser.on("-x", "Deletes the last entry from the logfile.") { clear_last_entry = true }
        parser.on("-h", "--help", "Show this help") { abort(parser) }
      end

      logfile = Logfile.new("foo.sqlite")

      case
      when search_text
        puts "Search text: #{search_text}"
        logfile.search_entries(search_text).each do |entry|
          body = entry[0]
          type = entry[1]
          project = entry[2]
          created_at = entry[3]

          puts "#{created_at} - #{body}"
        end
      when clear_last_entry
        logfile.clear_last_entry
      when ARGV[0]? && ARGV[0] == "-"
        lines = [] of String
        while (line = STDIN.gets)
          lines << line
        end
        body = lines.join("\n")
        logfile.add_entry(body, type, project)
      when ARGV[0]?
        body = ARGV[0..-1].join(" ")
        logfile.add_entry(body, type, project)
      else
        logfile.entries.each do |entry|
          body = entry[0]
          type = entry[1]
          project = entry[2]
          created_at = entry[3]

          puts created_at
          puts "Type: #{type}".colorize(:blue) if type
          puts "Project: #{project}".colorize(:yellow) if project
          puts
          puts body
          puts
        end
      end
    end
  end
end
