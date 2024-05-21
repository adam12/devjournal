require "sqlite3"

module DevJournal
  class Logfile
    @db : DB::Database
    property :db

    def initialize(@logfile : String)
      @db = DB.open("sqlite3://" + @logfile)

      create_entries_table
    end

    def add_entry(body, type, project)
      sql = "INSERT INTO entries(body, type, project) VALUES(?, ?, ?)"
      db.exec(sql, body, type, project)
    end

    def entries
      sql = "SELECT body, type, project, created_at FROM ENTRIES ORDER BY created_at DESC"
      db.query(sql)
    end

    def search_entries(q)
      sql = "SELECT body, type, project, created_at FROM ENTRIES WHERE body LIKE ? ORDER BY created_at DESC"
      db.query(sql, "%#{q}%")
    end

    def clear_last_entry
      sql = "DELETE FROM entries WHERE id=(SELECT id FROM entries ORDER BY created_at DESC LIMIT 1) LIMIT 1"
      db.exec(sql)
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

      db.exec(sql)
    end
  end
end
