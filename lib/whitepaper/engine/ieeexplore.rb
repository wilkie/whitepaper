module Whitepaper
  module Engine
    # This engine uses the IEEEXplore database to query metadata about a paper.
    module IEEEXplore
      # The domain for IEEEXplore.
      DOMAIN = "http://ieeexplore.ieee.org"

      # The url to use to search by title keywords.
      SEARCH_BY_TITLE_URL = "search/searchresult.jsp?reload=true&newsearch=true&queryText={title}&x=60&y=7"

      class << self
        # Returns a url that will query for the given title keywords
        def find_by_title_url(title)
          "#{DOMAIN}/#{SEARCH_BY_TITLE_URL.gsub(/\{title\}/, title.gsub(/\s/, "+"))}"
        end

        # Returns a Whitespace::Paper by searching for the paper with the given title keywords.
        def find_by_title(title)
          @agent = Mechanize.new
          page = @agent.get "#{find_by_title_url(title)}"

          # get the first link
          paper = page.search '//div[@class="detail"]/h3/a'

          paper_link = "#{DOMAIN}#{paper.first.attribute("href")}"

          retrieve_details paper_link
        end

        # Returns a Whitespace::Paper by reading the direct page for a particular paper.
        def retrieve_details(url)
          @agent = Mechanize.new

          page = @agent.get url

          get_meta = lambda {|name|
            meta = page.search "//meta[@property=\"#{name}\"]"
            if meta.nil? or meta.first.nil?
              return ""
            end
            meta.first.attribute("content").to_s
          }

          keywords_raw = get_meta.call("keywords")
          title = get_meta.call("citation_title")
          year = get_meta.call("citation_date")
          year = year[-4..-1] unless year.empty?
          conference = get_meta.call("citation_conference")

          authors = []
          meta = page.search "//meta[@property=\"citation_author\"]"
          meta.each do |e|
            authors << e.attribute("content").to_s.strip
          end

          keywords = keywords_raw.to_s.split(';').map(&:strip)

          links = []
          ps_links = []

          Paper.new title, authors, {:description  => "",
                                     :keywords     => keywords,
                                     :year         => year,
                                     :conference   => conference,
                                     :metadata_url => url,
                                     :pdf_urls     => links,
                                     :ps_urls      => ps_links}
        end
      end
    end
  end
end
