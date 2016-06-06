require "option_parser"
require "colorize"
require "tempfile"

module DevJournal
  class CLI
    @type : String | Nil
    @project : String | Nil
    @search_text : String | Nil
    @clear_last_entry = false

    def initialize(@argv : Array(String))
      parse_options

      filename = File.expand_path("~/log.sqlite3")

      @logfile = Logfile.new(filename)
    end

    def run
      case
      when @search_text then search
      when @clear_last_entry then clear_last_entry
      when @argv[0]? && @argv[0] == "-" then editor_input
      when @argv[0]? then argv_input
      else show_recent_entries
      end
    end

    def search
      entries = @logfile.search_entries(@search_text)
      display_entries(entries)
    end

    def show_recent_entries
      entries = @logfile.entries
      display_entries(entries)
    end

    def display_entries(entries)
      if STDIN.tty?
        pager = ENV.fetch("PAGER", "less")

        Process.run(pager, output: true) do |proc|
          display_entries(entries, proc.input)
          proc.input.close
        end
      else
        display_entries(entries, STDOUT)
      end
    end

    def display_entries(entries, output)
      entries.each do |entry|
        body = entry[0]
        type = entry[1]
        project = entry[2]
        created_at = entry[3]

        output.puts created_at
        output.puts "Type: #{type}".colorize(:blue) if type
        output.puts "Project: #{project}".colorize(:yellow) if project
        output.puts
        output.puts body
        output.puts
      end
    end

    def editor_input
      body = [] of String
      editor = ENV.fetch("EDITOR", "vim")

      tempfile = Tempfile.new("devjournal")
      system(editor, [tempfile.path])

      if $?.normal_exit?
        body = File.read(tempfile.path)

        if !body.empty?
          add_entry(body)
        else
          STDERR.puts "Skipping empty entry"
        end
      end

      tempfile.unlink
    end

    def stdin_input
      lines = [] of String

      while (line = STDIN.gets)
        lines << line
      end

      body = lines.join("\n")
      add_entry(body)
    end

    def argv_input
      body = ARGV[0..-1].join("\n")
      add_entry(body)
    end

    def add_entry(body)
      @logfile.add_entry(body, @type, @project)
    end

    def clear_last_entry
      @logfile.clear_last_entry
    end

    def parse_options

      OptionParser.parse! do |parser|
        parser.banner = "Usage: #{$0} [arguments]"
        parser.on("-t TYPE", "--type=TYPE", "The type classification that the log event belongs to. example: work, school etc.") { |t| @type = t }
        parser.on("-p PROJECT", "--project=PROJECT", "The project that the log event belongs to. This helps group log events together
                                     which might belong to the same type or which my not belong to a type at all.") { |p| @project = p }

        parser.on("-s TEXT", "Case insensitive search of the log file for the given text.") { |s| @search_text = s }
        parser.on("-x", "Deletes the last entry from the logfile.") { @clear_last_entry = true }
        parser.on("-h", "--help", "Show this help") { abort(parser) }
        parser.on("-v", "--version", "Show the version") { abort("Log v#{DevJournal::VERSION}") }
      end
    rescue ex
      puts abort(ex.message)
    end

    def self.run
      self.new(ARGV).run
    end
  end
end
