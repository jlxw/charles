module Charles
  module Misc
    def self.compare_strings(a,b)
      [compare_strings_single_side(a,b),compare_strings_single_side(b,a)].mean
    end
    def self.compare_strings_single_side(a,b)
      index = Ferret::Index::Index.new()
      index.field_infos.add_field(:content, :store => :no, :boost => 1)
      index << {:content => a}
      search = index.search(b.gsub(/[:()\[\]{}!+"~^\-|<>=*?\\]/,'')) #remove special charcaters used by ferret query parser: http://www.davebalmain.com/api/classes/Ferret/QueryParser.html, http://www.regular-expressions.info/charclass.html
      search.max_score
    end
    
    
    
  
    def self.analyzer
      @analyzer ||= (
        #http://blackwinter.github.com/ferret/classes/Ferret/Analysis.html
        stop_words = Ferret::Analysis::EXTENDED_ENGLISH_STOP_WORDS |
                      Ferret::Analysis::FULL_FRENCH_STOP_WORDS |
                      Ferret::Analysis::FULL_SPANISH_STOP_WORDS |
                      Ferret::Analysis::FULL_PORTUGUESE_STOP_WORDS |
                      Ferret::Analysis::FULL_ITALIAN_STOP_WORDS |
                      Ferret::Analysis::FULL_GERMAN_STOP_WORDS |
                      Ferret::Analysis::FULL_DUTCH_STOP_WORDS |
                      Ferret::Analysis::FULL_SWEDISH_STOP_WORDS |
                      Ferret::Analysis::FULL_NORWEGIAN_STOP_WORDS |
                      Ferret::Analysis::FULL_DANISH_STOP_WORDS |
                      Ferret::Analysis::FULL_RUSSIAN_STOP_WORDS |
                      Ferret::Analysis::FULL_FINNISH_STOP_WORDS
        Ferret::Analysis::StandardAnalyzer.new(stop_words,true)#(Ferret::Analysis::FULL_ENGLISH_STOP_WORDS) #no stop words
      )
    end
  
  
    def self.string_to_tokens(string)
      token_stream = self.analyzer.token_stream('',string)
      o=[]; while(j=token_stream.next); o << j.text unless o.include?(j.text); end;
      return o
    end
    def self.string_to_clean_tokens(string)
      tokens = string_to_tokens(string)
      tokens.delete_if{|token| token.match(/\d/)}
      tokens
    end
    def self.string_to_clean_tokens_string(string)
      string_to_clean_tokens(string).join(' ')
    end
    
    
    
    
    
    
    def self.normalize_string(string)
      @htmlentities||=HTMLEntities.new
      @htmlentities.decode(normalize_unicode_characters(string.gsub(/[\s\302\240]+/,' ').strip))
    end
    UNICODE_CONVERSIONS = {
      "8230" => '...',
      "8194" => ' ',
      "8195" => ' ',
      "8201" => ' ',
      "8211" => '-',
      "8216" => '\'',
      "8217" => '\'',
      "8220" => '"',
      "8221" => '"'
    }
    TRANSLATED_CONVERSIONS = UNICODE_CONVERSIONS.map {|k, v| [[k.to_i].pack('U*'), v] }
    def self.normalize_unicode_characters(string)
      TRANSLATED_CONVERSIONS.each {|k,v| string.gsub! k, v }
      string
    end
  end
end