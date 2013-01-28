module Whitepaper
  # The representation of a paper, including title, author, and pdf urls.
  class Paper
    # The title of the paper.
    attr_reader :title

    # The list of authors of the paper.
    attr_reader :authors

    # A summary of the paper, typically an abstract. Defaults to "".
    attr_reader :description

    # A list of keywords associated with the paper. Defaults to [].
    attr_reader :keywords

    # The year of publication. Defaults to "".
    attr_reader :year

    # The conference, if any, the paper appeared. Defaults to "".
    attr_reader :conference

    # The link to the resource with the most metadata to use as attribution.
    # Defaults to "".
    attr_reader :metadata_url

    # A list of urls to pdf copies of the paper. Defaults to [].
    attr_reader :pdf_urls

    # A list of urls to ps copies of the paper. Defaults to [].
    attr_reader :ps_urls

    # Construct an object representing paper metadata with the given fields.
    # Title and authors are required, all other fields can be omitted.
    def initialize(title, authors, options = {})
      @title = title
      @authors = authors
      @description = options[:description] || ""
      @keywords = options[:keywords] || []
      @year = options[:year] || ""
      @conference = options[:conference] || ""
      @metadata_url = options[:metadata_url] || ""

      @pdf_urls = options[:pdf_urls] || []
      @ps_urls = options[:ps_urls] || []
    end

    # Downloads the paper by using the pdf urls. The created file will be named
    # after the title if no filename is given. The file will overwrite any existing
    # file with the same name in the current directory.
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

    # Gives a score of relevancy to the title keywords given. Higher scores
    # mean that the keywords are more reflective of the title.
    def score_by_title(keywords)
      keywords = keywords.split(" ").map(&:strip).map(&:downcase)
      title_words = title.split(" ").map(&:strip).map(&:downcase)

      score = 1.0

      # found words are worth x10
      # not found words are worth /2
    
      keywords.each do |k|
        if title_words.include? k
          score *= 10.0
        end
      end

      title_words.each do |k|
        unless keywords.include? k
          score /= 2.0
        end
      end

      score
    end

    # Output a simple description of the paper metadata.
    def to_s
      "Title:       #{@title}\n" +
      "Authors:     #{@authors}\n" +
      "Description: #{@description}\n" +
      "Keywords:    #{@keywords}\n" +
      "Year:        #{@year}\n" +
      "Conference:  #{@conference}\n" + 
      "More info:   #{@metadata_url}\n" +

      "Pdf Available: #{@pdf_urls}\n" +
      "Ps Available: #{@ps_urls}"
    end
  end
end
