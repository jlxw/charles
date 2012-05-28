module Charles
  module InternalAttributes
    
    #https://github.com/cheald/pismo/blob/master/lib/pismo/document.rb

    TITLE_MATCHES = [
      '#pname a', # Google Code style
      '.entryheader h1', # Ruby Inside/Kubrick
      '.entry-title a', # Common Blogger/Blogspot rules
      '.post-title a',
      '.post_title a',
      '.posttitle a',
      '.post-header h1',
      '.entry-title',
      '.post-title',
      '.post h1',
      '.post h3 a',
      'a.datitle', # Slashdot style
      '.posttitle',
      '.post_title',
      '.pageTitle',
      '#main h1.title',
      '.title h1',
      '.post h2',
#      'h2.title', #false positive for latimes.com
      '.entry h2 a',
      '.entry h2', # Common style
      '.boite_titre a',
      ['meta[@name="title"]', lambda { |el| el.attr('content') }],
      'h1.headermain',
      'h1.title',
      '.mxb h1', # BBC News
      '#content h1',
      '#content h2',
      '#content h3',
      'a[@rel="bookmark"]',
      '.products h2',
      '.caption h3',
#      '#main h2', #false positive for nytimes.com
      '#body h1',
      '#wrapper h1',
      '#page h1',
      '.asset-header h1',
      '#body_content h2'
    ]
    
    def title
      @title ||= titles.first
    end
    def titles
      @all_titles ||= begin
        [ @document.match(TITLE_MATCHES), html_title ].flatten.compact.uniq
      end
    end
    # HTML title
    def html_title
      @html_title ||= begin
        if title = @document.match('title').first
          title
        else
          nil
        end
      end
    end
  end
end