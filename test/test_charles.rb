require 'test/unit'
require 'charles'
require 'yaml'
#require 'active_support/testing/assertions'

TEST_ARTICLES = YAML.load_file("test/articles.yml")

class CharlesTest < Test::Unit::TestCase
  #include ActiveSupport::Testing::Assertions

  def setup
  end
  
  def test_articles
    TEST_ARTICLES.each{|article|
      next if article[:file].empty?
      input = File.read("test/articles/#{article[:file]}.html")
      document = Charles::Document.new(input, :url => article[:url])
      result = document.content
      expected = File.read("test/articles/#{article[:file]}.content.txt")
      #pp Charles::Misc.compare_strings(result, expected)

      _title_score = Charles::Misc.compare_strings(document.title, article[:expected][:title])
        pp [document.title, article[:expected][:title], _title_score]
      if _title_score < 0.1
#        pp [document.title, article[:expected][:title], _title_score]
      end
      
      unless document.image == article[:expected][:image] || !article[:expected][:image]
        #pp(document.images.index(article[:expected][:image]))
      end
    }
  end
  
  def test_clean_title
    article = TEST_ARTICLES.detect{|article| article[:url] == 'http://online.wsj.com/article/SB10001424052702303674004577433160886451978.html'}
    input = File.read("test/articles/#{article[:file]}.html")
    sample_titles = ['Former ML closer Armando Benitez signs with Ducks - WSJ.com',
      'The Top 10 Clean-Tech Companies - WSJ.com',
      'Book Review: Internal Time - WSJ.com',
      'NASA Working With Private Sector — Letters to the Editor - WSJ.com',
      'NASA Working With Private Sector — Letters to the Editor - WSJ.com',
      'San Francisco Symphony Orchestra | Radicals Ready for the Road - WSJ.com']
    document = Charles::Document.new(input, :url => article[:url], :sample_titles => sample_titles)
    pp document.clean_title
  end
  
  
end