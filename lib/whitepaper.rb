require "whitepaper/version"

require 'whitepaper/engine/citeseerx'
require 'whitepaper/engine/google'

module Whitepaper
  class << self
    def find_by_title(title)
      paper = Engine::CiteSeerX.find_by_title(title)

      if paper.pdf_urls.empty?
        g = Engine::Google.find_by_title(title)

        paper = Paper.new(paper.title,
                          paper.authors,
                          {:description => paper.description,
                           :keywords => paper.keywords,
                           :year => paper.year,
                           :conference => paper.conference,
                           :pdf_urls => g.pdf_urls,
                           :ps_urls => paper.ps_urls})
      end

      paper
    end

    def find_authors_by_title(title)
      paper = find_by_title(title)

      if paper
        paper.authors
      end
    end

    def find_title_by_title(title)
      paper = find_by_title(title)

      if paper
        paper.title
      end
    end

    def find_pdfs_by_title(title)
      paper = find_by_title(title)

      if paper
        paper.pdf_urls
      end
    end

    def download_pdf_by_title(title)
      paper = find_by_title(title)
      paper.download
    end
  end
end
