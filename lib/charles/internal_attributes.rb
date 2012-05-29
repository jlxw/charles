module Charles
  module InternalAttributes
    def title
      @title||=(
        title = @document.search('title').first
        title ? title.clean_inner_text : nil
      )
    end
    def clean_title
      return title if !@options[:sample_titles] || @options[:sample_titles].size < 5
      _title_words = {}
      
      _tokens = Charles::Misc.string_to_tokens_raw(self.title, type = :no_stop_words)
      while(_tokens.first && words_to_filter_from_sample_titles.include?(_tokens.first.text)); _tokens.shift; end; #remove words from the beginning of the tokens
      while(_tokens.last && words_to_filter_from_sample_titles.include?(_tokens.last.text)); _tokens.pop; end; #remove words from the end of the tokens
      return title if _tokens.empty? #everything stripped? return nil, use other titles
  
      _start = _tokens.first.start;
      _end = _tokens.last.end;
      _title = self.title.slice(_start, _end - _start)
      _title = self.title.match(/[^\s\302\240]*#{Regexp.escape(_title)}[^\s\302\240]*/)[0].strip #include symbols or punctuation surrounding the title
    end
    
    protected
    
    def words_to_filter_from_sample_titles
      @words_to_filter_from_sample_titles = calculate_words_to_filter_from_sample_titles
    end
    def calculate_words_to_filter_from_sample_titles
      _title_words = {}
      @options[:sample_titles].each{|sample_title|
        Charles::Misc.string_to_tokens(sample_title, type = :no_stop_words).uniq.each{|token|
          _title_words[token]||=0; _title_words[token]+=1
        }
      }
      _threshold = (0.9 * @options[:sample_titles].size).ceil
      _words_to_filter = _title_words.select{|k,v| v >= _threshold}.collect{|k,v| k} #select words used in more than 90% of the titles
    end
  end
end