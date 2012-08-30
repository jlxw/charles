require 'test/unit'
require 'charles'
require 'yaml'
#require 'active_support/testing/assertions'

YAML::ENGINE.yamler = 'syck'
TEST_ARTICLES = YAML.load_file("test/articles.yml")

Charles.options[:tmp_path] = File.dirname(__FILE__) + "/tmp"  

class CharlesTest < Test::Unit::TestCase
  #include ActiveSupport::Testing::Assertions

  def setup
  end
  
  def test_articles
    _scores = {:content => [], :title => [], :image => []}
    TEST_ARTICLES.each{|article|
      next if article[:file].empty?
      input = File.read("test/articles/#{article[:file]}.html").encode('UTF-8', :invalid => :replace)
      document = Charles::Document.new(input, :url => article[:url])
      result = document.content
      expected = File.read("test/articles/#{article[:file]}.content.txt")
      content_score = Charles::Misc.compare_strings(result, expected)
      #pp [content_score, result, expected, article[:url]] if content_score < 0.1
      _scores[:content] << content_score
      title_score = Charles::Misc.compare_strings(document.title, article[:expected][:title])
      #pp [title_score, document.title, article[:expected][:title], article[:url]] if title_score < 0.1
      _scores[:title] << title_score
      
      if article[:expected][:image]
        _scores[:image] << (document.images.index(article[:expected][:image]) ? 1 : 0)
      end
    }
    
    assert _scores[:content].select{|score| score < 0.5}.mean > 0.2
    assert _scores[:content].select{|score| score < 0.1}.size < 4
    assert _scores[:content].select{|score| score < 0.01}.size < 1
    assert _scores[:title].select{|score| score < 0.5}.mean > 0.15
    assert _scores[:title].select{|score| score < 0.1}.size < 5
    assert _scores[:title].select{|score| score < 0.01}.size < 2
    assert _scores[:image].mean > 0.4
  end
  
  def test_clean_title
    article = TEST_ARTICLES.detect{|article| article[:url] == 'http://online.wsj.com/article/SB10001424052702303674004577433160886451978.html'}
    input = File.read("test/articles/#{article[:file]}.html")
    sample_titles = ['Former ML closer Armando Benitez signs with Ducks - WSJ.com',
      'The Top 10 Clean-Tech Companies - WSJ.com',
      'Book Review: Internal Time - WSJ.com',
      'NASA Working With Private Sector Letters to the Editor - WSJ.com',
      'San Francisco Symphony Orchestra | Radicals Ready for the Road - WSJ.com']
    document = Charles::Document.new(input, :url => article[:url], :sample_titles => sample_titles)
    assert document.title.include?('WSJ.com')
    assert !document.clean_title.include?('WSJ.com')
  end
  
  def test_filtered_images
    article = TEST_ARTICLES.detect{|article| article[:url] == 'http://online.wsj.com/article/SB10001424052702303674004577433160886451978.html'}
    input = File.read("test/articles/#{article[:file]}.html")
    document = Charles::Document.new(input, :url => article[:url])
    filtered_images_extra = document.filtered_images_extra
    assert filtered_images_extra.size > 3
    assert filtered_images_extra.last[:data].size > 1000
    assert filtered_images_extra.last[:width] > 100
    assert filtered_images_extra.last[:height] > 100
  end
  
end
