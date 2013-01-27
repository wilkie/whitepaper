require 'mechanize'

require 'whitepaper/paper'

module Whitepaper
  module Engine
    module Google
      class << self
        def find_by_title(title)
          @agent = Mechanize.new

          page = @agent.get "https://www.google.com/search?q=#{URI::encode(title)}+filetype%3Apdf"

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
            Paper.new(urls[0][:title], urls[0][:authors], {:pdf_urls => [urls[0][:url]]})
          else
            nil
          end
        end
      end
    end
  end
end

