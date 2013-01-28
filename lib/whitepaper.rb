require "whitepaper/version"

require 'whitepaper/engine/acm'
require 'whitepaper/engine/citeseerx'
require 'whitepaper/engine/google'

# The namespace for the available metadata gathering engines.
module Whitepaper::Engine
end

# The main module encapsulating Whitepaper resources.
module Whitepaper
  class << self
    # Find and return a Whitepaper::Paper by searching for a partial match with the given title.
    def find_by_title(title)
      paper_csx = Engine::CiteSeerX.find_by_title(title)
      paper_acm = Engine::ACM.find_by_title(title)
      paper_i3e = Engine::ACM.find_by_title(title)

      paper = [paper_csx, paper_i3e, paper_acm].sort{|a,b| b.score_by_title(title) <=> a.score_by_title(title)}.first

      # Gather pdf and ps links across the open internet
      g = Engine::Google.find_by_title(title)

      paper = Paper.new(paper.title,
                        paper.authors,
                        {:description => paper.description,
                         :keywords => paper.keywords,
                         :year => paper.year,
                         :conference => paper.conference,
                         :pdf_urls => paper.pdf_urls.concat(g.pdf_urls),
                         :ps_urls => paper.ps_urls.concat(g.ps_urls)})

      paper
    end

    # Find and return a list of authors by searching for a partial match with the given title.
    def find_authors_by_title(title)
      paper = find_by_title(title)

      if paper
        paper.authors
      end
    end

    # Find and return the proper title by searching for a partial match with the given title.
    def find_title_by_title(title)
      paper = find_by_title(title)

      if paper
        paper.title
      end
    end

    # Find and return a list of pdf urls by searching for a partial match with the given title.
    def find_pdfs_by_title(title)
      paper = find_by_title(title)

      if paper
        paper.pdf_urls
      end
    end

    # Downloads the first available pdf by searching for a partial match with the given title.
    # The name of the file will be the title of the paper.
    def download_pdf_by_title(title)
      paper = find_by_title(title)
      paper.download
    end
  end
end
