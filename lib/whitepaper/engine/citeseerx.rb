require 'mechanize'

require 'whitepaper/paper'

module Whitepaper
  module Engine
    module CiteSeerX
      DOMAIN = "http://citeseerx.ist.psu.edu"
      SEARCH_BY_TITLE_URL = "search?q=title%3A{title}&t=doc&sort=cite"

      class << self
        def find_by_title_url(title)
          "#{DOMAIN}/#{SEARCH_BY_TITLE_URL.gsub(/\{title\}/, title)}"
        end

        def find_by_title(title)
          @agent = Mechanize.new
          page = @agent.get "#{find_by_title_url(title)}"

          # get the first link
          paper = page.search '//div[@id="result_list"]/div[@class="result"]/h3/a'

          paper_link = "#{DOMAIN}#{paper.first.attribute("href")}"

          retrieve_details paper_link
        end

        def retrieve_details(url)
          @agent = Mechanize.new

          page = @agent.get url

          def get_meta(name, page)
            meta = page.search "//meta[@name=\"#{name}\"]"
            if meta.nil? or meta.first.nil?
              return ""
            end
            meta.first.attribute "content"
          end

          description = get_meta("description", page)
          keywords_raw = get_meta("keywords", page)
          title = get_meta("citation_title", page)
          authors_raw = get_meta("citation_authors", page)
          year = get_meta("citation_year", page)
          conference = get_meta("citation_conference", page)

          authors = authors_raw.to_s.split(',').map(&:strip)
          keywords = keywords_raw.to_s.split(',').map(&:strip)

          links = []
          ps_links = []

          link_url = page.search '//ul[@id="clinks"]/li/a'
          link_url.each do |l|
            url = "#{DOMAIN}#{l.attribute("href").to_s}"
            if url.end_with? "pdf"
              links << url
            end
            if url.end_with? "ps"
              ps_links << url
            end
          end

          link_url = page.search '//ul[@id="dlinks"]/li/a'
          link_url.each do |l|
            url = l.attribute("href").to_s
            if url.end_with? "pdf"
              links << url
            end
            if url.end_with? "ps"
              ps_links << url
            end
          end

          Paper.new title, authors, {:description => description,
                                     :keywords    => keywords,
                                     :year        => year,
                                     :conference  => conference,
                                     :pdf_urls    => links,
                                     :ps_urls     => ps_links}
        end
      end
    end
  end
end

