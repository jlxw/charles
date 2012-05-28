require 'test/unit'
require 'charles'
require 'yaml'
require 'pp' 
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
      if _title_score < 0.1
        #pp [document.title, article[:expected][:title], _title_score]
      end
      
      unless document.image == article[:expected][:image] || !article[:expected][:image]
        pp(document.images.index(article[:expected][:image]))
      end
    }
  end
  
  
end