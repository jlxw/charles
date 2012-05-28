#!/usr/bin/env ruby

require 'lib/charles'
require 'yaml'
require 'pp' 

TEST_ARTICLES = YAML.load_file("test/articles.yml")

class CharlesOptimiser
  @@high_score = 0
  
  def initialize
    @articles = YAML.load_file("test/articles.yml")
    @articles.each{|article|
      next if article[:file].empty?
      article[:html] = File.read("test/articles/#{article[:file]}.html")
      article[:document] = Charles::Document.new(article[:html])
      article[:expected][:content] = File.read("test/articles/#{article[:file]}.content.txt")
    }
  end
  def optimise
    50.times do
      seeds = {
        :length => random(800,3000),
        :distance_from_top => random(0.1,2),
        :internal_nodes => random(5,50),
        :internal_nodes_buffer => random(5,150),
        :title_match => random(0,1),
        :title_match_buffer => random(0,0.6)
      }
      _scores = articles_scores(seeds)
      _scores.delete_if{|score| score > 1}
      _score = _scores.mean
      _std_dev = _scores.standard_deviation
      if _score >= @@high_score
        @@high_score = _score
        pp [_score, _std_dev, seeds, _scores.select{|i| i<0.1}.size]
      end
    end
  end
  def articles_scores(seeds={})
    _scores = []
    @articles.each{|article|
      next if article[:file].empty?
      result = article[:document].content(seeds)
      _score = compare_articles(result, article[:expected][:content])
      _scores << _score
    }
    _scores
  end
  def compare_articles(a,b)
    [compare_articles_single_side(a,b),compare_articles_single_side(b,a)].mean
  end
  def compare_articles_single_side(a,b)
    index = Ferret::Index::Index.new()
    index.field_infos.add_field(:content, :store => :no, :boost => 1)
    index << {:content => a}
    search = index.search(b)
    search.max_score
  end
  
  def random(min,max)
    rand * (max - min) + min
  end
end

while true
thread = Thread.new {
  CharlesOptimiser.new.optimise
}
thread.join
puts "***"
end