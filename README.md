# Whitepaper

This gem will perform a whitepaper lookup on major scholarly databases. It's purpose is to easily find
related papers and organize your paper collection. With this application, you can easily download pdfs
or use it as a library to automatically assign metadata.

Currently, CiteSeerX, ACM and IEEE are the only databases it uses along with a
google pdf/ps search to find other pdf or ps links to download.

## Installation

Add this line to your application's Gemfile:

    gem 'whitepaper'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install whitepaper

## Command-line Usage

The command-line tool makes it easy to find metadata and download pdf copies of
papers found via keyword search. It is really only designed for personal use.

Display usage:

    whitepaper -h

Finding article metadata by title keyword search:

    whitepaper -t "corey multicore"

With no other options, this will print out all information about the paper.

If you want to limit what the program prints, then add one or more output flags:

Printing the article's proper title:

    whitepaper -n -t "xomb multicore"

Printing the article's list of authors:

    whitepaper -a -t "ubiquitous computing"

Printing the article's pdf url:

    whitepaper -p -t "exokernel"

Finally, you can simply have the app download an article and place it in the
current directory. It will name the file as closely to the title as it can.

Download a pdf by any means necessary by title keyword search:

    whitepaper -d -t "The Design and Implementation of a Log-Structured File System"

### Programmable

To get paper metadata, add whitepaper to your Gemfile:

    gem 'whitepaper'

And require it if necessary: (Your project may auto require libraries in your Gemfile)

    require 'whitepaper'

Invoke with this simple command to look up a paper with the given terms in the title:

    paper = Whitepaper.find_by_title("hierarchial filesystems are dead")

This will give you back a Whitepaper::Paper object! To get a pdf url, just go:

    paper.pdf_urls.first unless paper.pdf_urls.empty?

As you can see, you can get a list of pdf links, so you can try each until you find one
that actually exists, or as a mirror if the server is down. If postscript is your thing, then check
out ps_urls and follow the same steps.

To get other metadatas, just follow one of the following lines of code:

    title       = paper.title
    authors     = paper.authors
    description = paper.description
    year        = paper.year
    conference  = paper.conference
    keywords    = paper.keywords

A field that does not have a value will be a blank string or an empty array. Use the
empty? method on what is returned in either case to check
for a field that is, well, empty.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Please refer to the LICENSE file in this repo for distribution information.
Whitespace uses an unaltered MIT license, which is a permissive open source
license. If this is unacceptable for you, please defer to the copyright holder.

### TODO

1. Add new output options (JSON, YAML, etc) for better metadata usage by other programs.
2. Add new engines (Google Scholar, etc)
