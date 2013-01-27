module Whitepaper
  class Paper
    attr_reader :title
    attr_reader :authors
    attr_reader :description
    attr_reader :keywords
    attr_reader :year
    attr_reader :conference

    attr_reader :pdf_urls
    attr_reader :ps_urls

    def initialize(title, authors, options = {})
      @title = title
      @authors = authors
      @description = options[:description] || ""
      @keywords = options[:keywords] || []
      @year = options[:year] || ""
      @conference = options[:conference] || ""

      @pdf_urls = options[:pdf_urls] || []
      @ps_urls = options[:ps_urls] || []
    end

    def download(filename = nil)
      if filename.nil?
        filename = title.to_s
      end
      escaped_filename = filename.gsub(/[\t:\?\<\>\*\"\\\/]/, "") + ".pdf"

      f = open(escaped_filename, "w+")

      if pdf_urls.empty?
        return false
      end

      uri = URI.parse(pdf_urls.first)
      begin
        Net::HTTP.start(uri.host, uri.port) do |http|
          http.request_get(uri.request_uri) do |resp|
            resp.read_body do |segment|
              f.write(segment)
            end
          end
        end
      ensure
        f.close()
      end

      true
    end

    def to_s
      "Title:       #{@title}\n" +
      "Authors:     #{@authors}\n" +
      "Description: #{@description}\n" +
      "Keywords:    #{@keywords}\n" +
      "Year:        #{@year}\n" +
      "Conference:  #{@conference}\n" + 

      "Pdf Available: #{@pdf_urls}\n" +
      "Ps Available: #{@ps_urls}"
    end
  end
end
