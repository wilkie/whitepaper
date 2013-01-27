require 'optparse'

require 'whitepaper'

module Whitepaper
  class CLI
    BANNER = <<-USAGE
    USAGE

    class << self
      def parse_options
        @opts = OptionParser.new do |opts|
          opts.banner = BANNER.gsub(/^    /, '')

          opts.separator ''
          opts.separator 'Options:'

          opts.on('-h', '--help', 'Display this help') do
            puts opts
            exit 0
          end

          opts.on('-f', '--find KEYWORDS', 'Display the data for the paper with the given KEYWORDS') do |title|
            puts Whitepaper.find_by_title(title)

            exit 0
          end
          
          opts.on('-d', '--download KEYWORDS', 'Downloads a pdf of the paper with the given KEYWORDS') do |title|
            Whitepaper.download_pdf_by_title(title)

            exit 0
          end

          opts.on('-p', '--pdf KEYWORDS', 'Display a link to the pdf for the given KEYWORDS') do |title|
            puts Whitepaper.find_pdfs_by_title(title).first

            exit 0
          end

          opts.on('-n', '--name KEYWORDS', 'Display the title of the paper found with the given KEYWORDS') do |title|
            puts Whitepaper.find_title_by_title(title)

            exit 0
          end
        end

        @opts.parse!
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
