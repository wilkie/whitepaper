require 'mechanize'

require 'whitepaper/paper'

module Whitepaper
  module Engine
    # This engine simply uses a google filetype:pdf search to find paper information.
    module Google
      class << self
        # Return the url and title of the first result as a hash with keys :url and :title.
        def find(url)
          @agent = Mechanize.new

          page = @agent.get url 

          results = page.search '//h3[@class="r"]'

          urls = results.map do |r|
            a = r.search './a'

            # sanitize
            url = a.attribute "href"

            url = url.to_s.match(/\/url\?q=([^&]+)&/)[1]

            title = a.first.content

            author = r.search '../div[@class="s"]/span[@class="f"]'

            authors = author.map do |e|
              e.content.to_s
            end

            {:url => url, :title => title, :authors => authors}
          end

          if urls.length > 0
            urls.first
          else
            nil
          end
        end

        # Finds a Whitespace::Paper by looking up a paper with the given title keywords.
        def find_by_title(title)
          pdf = find("https://www.google.com/search?q=#{URI::encode(title)}+filetype%3Apdf")
          ps = find("https://www.google.com/search?q=#{URI::encode(title)}+filetype%3Aps")

          pdf_urls = []
          ps_urls = []

          pdf_score = score(pdf[:title], title)
          ps_score  = score(ps[:title],  title)

          if pdf and pdf_score >= ps_score
            pdf_urls << pdf[:url]
          end

          if ps and ps_score >= pdf_score
            ps_urls << ps[:url]
          end

          Paper.new(pdf[:title], [], {:pdf_urls => pdf_urls,
                                      :ps_urls  => ps_urls})
        end

        # Get an early score rating
        #--
        # TODO: move into own class for Whitepaper::Paper
        def score(title, keywords)
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
      end
    end
  end
end

