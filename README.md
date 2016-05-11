# DevJournal

I'd been reading [Jesper L. Andersen's](https://medium.com/@jlouis666/on-logbooks-e2380ab2f8f0) Medium post about
*logbooks* when something just clicked. **I needed to start my own logbook.**

Inspired by [Logger-TXT](https://github.com/grantlucas/Logger-TXT) by [Grant Lucas](https://github.com/grantlucas).

## Why another tool?

Although I like Logger-TXT, I wanted something built on SQLite.

## Installation


TODO: Write installation instructions here


## Usage

Upon first initialization, a logfile will be created at `~/log.sqlite3`.

### Display Log Entries

	$ devjournal

### Add a single line entry

	$ devjournal This is an example line entry

### Add a multiple line entry

	$ devjournal -

### Shorter CLI

Alias `devjournal` to `dj` for less keystrokes.

	$ alias dj='devjournal'

## Development

	$ git clone https://github.com/adam12/devjournal
	$ cd devjournal
	$ crystal deps
	$ crystal run src/dev_journal.cr

## Possible new features

* Markdown?
* Tags
* Date range search
* Custom log location

## Contributing

1. Fork it ( https://github.com/adam12/devjournal/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [adam12](https://github.com/adam12) Adam Daniels - creator, maintainer
