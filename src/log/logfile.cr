require "sqlite3"

module Log
  class Logfile
    def initialize(@logfile)
      @db = SQLite3::Database.new(@logfile)

      create_entries_table
    end

    def add_entry(body, type, project)
      sql = <<-SQL
        INSERT INTO entries(body, type, project) VALUES(?, ?, ?)
      SQL

      @db.execute(sql, body, type, project)
    end

    def entries
      @db.execute("SELECT body, type, project, created_at FROM ENTRIES ORDER BY created_at DESC")
    end

    def search_entries(q)
      @db.execute("SELECT body, type, project, created_at FROM ENTRIES WHERE body LIKE ? ORDER BY created_at DESC", "%#{q}%")
    end

    def clear_last_entry
      sql = <<-SQL
        DELETE FROM entries
      SQL

      @db.execute(sql)
    end

    def create_entries_table
      sql = <<-SQL
        CREATE TABLE IF NOT EXISTS entries (
          id INTEGER PRIMARY KEY NOT NULL,
          body TEXT,
          type VARCHAR(255),
          project VARCHAR(255),
          created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
      SQL

      @db.execute(sql)
    end
  end
end
