require 'mechanize'

module Whitepaper
  module Engine
    # This engine uses the ACM database to query metadata about a paper.
    module ACM
      # The domain to use for ACM.
      DOMAIN = "https://dl.acm.org"

      # The url to use to search by title.
      SEARCH_BY_TITLE_URL2 = "results.cfm?within={title_query}&adv=1&DL=ACM&termzone=Title&allofem={title}"

      SEARCH_BY_TITLE_URL = "results.cfm?query={title}&querydisp={title}&srt=score%20dsc&short=0&coll=DL&dl=GUIDE&source_disp=&source_query=&since_month=&since_year=&before_month=&before_year=&termshow=matchall&range_query="

      class << self
        # Returns a url that will query for the given title keywords.
        def find_by_title_url(title)
          "#{DOMAIN}/#{SEARCH_BY_TITLE_URL
            .gsub(/\{title\}/, title.gsub(/\s/, "+"))
            .gsub(/\{title_query\}/, "(Title:\"" + title.split(" ").join("\"+or+Title:\"") + "\")")}"
        end

        # Returns a Whitespace::Paper by searching for the paper with the given title keywords.
        def find_by_title(title)
          @agent = Mechanize.new

          # In case cookies are ever necessary to establish:
          #page = @agent.get("#{DOMAIN}")
          #search_url = page.search('//form[@name="qiksearch"]').first.attribute("action").to_s

          page = @agent.get(find_by_title_url(title))

          # get the first link
          paper = page.search '//a[@class="medium-text"]'

          paper_link = "#{DOMAIN}/#{paper.first.attribute("href")}"

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

          title = get_meta.call("citation_title")
          authors_raw = get_meta.call("citation_authors")
          year = get_meta.call("citation_date")
          year = year[-4..-1] unless year.empty?
          conference = get_meta.call("citation_conference")
          publisher = get_meta.call("citation_publisher")

          authors = authors_raw.to_s.split(';').map(&:strip).map do |s|
            index = s.index(',')
            if index > 0
              "#{s[index+2..-1]} #{s[0..index-1]}"
            else
              s
            end
          end

          links = []
          ps_links = []

          # get abstract
          abstract_url = page.content.match(/tab_abstract\.cfm\?.*cftoken\=\d+/)[0]
          abstract = @agent.get(abstract_url).root.text.to_s.strip

          Paper.new title, authors, {:description  => abstract,
                                     :keywords     => [],
                                     :metadata_url => url,
                                     :year         => year,
                                     :conference   => conference,
                                     :pdf_urls     => links,
                                     :ps_urls      => ps_links}
        end
      end
    end
  end
end
