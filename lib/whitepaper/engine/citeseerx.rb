require 'mechanize'

require 'whitepaper/paper'

module Whitepaper
  module Engine
    # This engine uses the CiteSeerX database to query metadata about a paper.
    module CiteSeerX
      # The domain to use for CiteSeerX.
      DOMAIN = "http://citeseerx.ist.psu.edu"

      # The url to use to search by title.
      SEARCH_BY_TITLE_URL = "search?q=title%3A{title}&t=doc&sort=cite"

      class << self
        # Returns a url that will query for the given title keywords.
        def find_by_title_url(title)
          "#{DOMAIN}/#{SEARCH_BY_TITLE_URL.gsub(/\{title\}/, title)}"
        end

        # Returns a Whitespace::Paper by searching for the paper with the given title keywords.
        def find_by_title(title)
          @agent = Mechanize.new
          page = @agent.get "#{find_by_title_url(title)}"

          # get the first link
          paper = page.search '//div[@id="result_list"]/div[@class="result"]/h3/a'

          if paper.empty?
            # no results
            return nil
          end

          paper_link = "#{DOMAIN}#{paper.first.attribute("href")}"

          retrieve_details paper_link
        end

        # Returns a Whitespace::Paper by reading the direct page for a particular paper.
        def retrieve_details(url)
          @agent = Mechanize.new

          page = @agent.get url

          get_meta = lambda {|name|
            meta = page.search "//meta[@name=\"#{name}\"]"
            if meta.nil? or meta.first.nil?
              return ""
            end
            meta.first.attribute("content").to_s
          }

          description = get_meta.call("description")
          keywords_raw = get_meta.call("keywords")
          title = get_meta.call("citation_title")
          authors_raw = get_meta.call("citation_authors")
          year = get_meta.call("citation_year")
          conference = get_meta.call("citation_conference")

          authors = authors_raw.to_s.split(',').map(&:strip)
          keywords = keywords_raw.to_s.split(',').map(&:strip)

          links = []
          ps_links = []

          link_url = page.search '//ul[@id="clinks"]/li/a'
          link_url.each do |l|
            purl = "#{DOMAIN}#{l.attribute("href").to_s}"
            if purl.end_with? "pdf"
              links << purl
            end
            if purl.end_with? "ps"
              ps_links << purl
            end
          end

          link_url = page.search '//ul[@id="dlinks"]/li/a'
          link_url.each do |l|
            purl = l.attribute("href").to_s
            if purl.end_with? "pdf"
              links << purl
            end
            if purl.end_with? "ps"
              ps_links << purl
            end
          end

          Paper.new title, authors, {:description  => description,
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

