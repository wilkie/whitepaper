require 'optparse'

require 'whitepaper'

module Whitepaper
  class CLI
    BANNER = <<-USAGE
    USAGE

    class << self
      def parse_options
        options = {}
        @opts = OptionParser.new do |opts|
          opts.banner = BANNER.gsub(/^    /, '')

          opts.separator ''
          opts.separator 'Options:'

          opts.on('-h', '--help', 'Display this help') do
            puts opts
            exit 0
          end

          opts.on('-t', '--by-title KEYWORDS', 'Display the data for the paper with the given KEYWORDS in title') do |title|
            options[:by_title] = title
          end
          
          opts.on('-d', '--download', 'Downloads a pdf of the paper of the paper found') do 
            options[:download] = true
          end

          opts.on('-p', '--pdf', 'Display a link to the pdf of the paper found') do
            options[:print_pdf_url] = true
          end

          opts.on('-n', '--name', 'Display the title of the paper found') do
            options[:print_title] = true
          end

          opts.on('-a', '--authors', 'Display the authors of the paper found') do
            options[:print_authors] = true
          end

        end

        @opts.parse!

        if options[:by_title]
          paper = Whitepaper.find_by_title(options[:by_title])

          if options[:print_title]
            puts paper.title
          end

          if options[:print_authors]
            puts paper.authors
          end

          if options[:print_pdf_url]
            unless paper.pdf_urls.empty?
              puts paper.pdf_urls.first
            end
          end

          unless options[:print_title] or
                 options[:print_authors] or
                 options[:print_pdf_url]
            puts paper
          end

          if options[:download] and not paper.pdf_urls.empty?
            puts "Downloading: " + paper.pdf_urls.first
            paper.download
          end
        else
          puts opts
        end
      end

      def CLI.run
        begin
          parse_options
        rescue OptionParser::InvalidOption => e
          warn e
          exit -1
        end

        def fail
          puts @opts
          exit -1
        end

        # Default
        puts BANNER
        exit 0
      end
    end
  end
end
