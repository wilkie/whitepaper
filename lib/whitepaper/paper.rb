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
