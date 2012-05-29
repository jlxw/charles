require 'charles/images'
require 'charles/internal_attributes'

module Charles
  class Document
    include Charles::InternalAttributes
    include Charles::Images
    
    def initialize(input, options={})
      @document = Nokogiri::HTML.parse(input)
      @document.search("script, style").remove
      @nodes = @document.search('body *').select{|_n|
        _n.clean_inner_tokens_text.size > 30 #arbitrary, minimum inner text limit of 30 chars
      }
      @options = options
    end
    
    def logger; Charles.logger; end
    
    def content(seeds={})
      content_node = content_node(seeds)
      return unless content_node
      refine_content_node(content_node).clean_inner_text
    end
    
    def content_node(seeds={})
      content_nodes = calculate_content_nodes(seeds)
      return unless content_nodes.first
      content_nodes.first[:node]
    end
    
    def calculate_content_nodes(seeds={})
      default_seeds = {:title_match=>0.145422959269808,
  :title_match_buffer=>0.0174920023610796,
  :length=>1100.27450832379,
  :distance_from_top=>0.308408501217311,
  :internal_nodes=>25.680381972181,
  :internal_nodes_buffer=>20.2006169153009}
      seeds = default_seeds.merge(seeds)
      
      o = []
      _rank = 0
      
      @nodes.each_index{|_i|
        _n = @nodes[_i]
        _rank += 1
        
        scores={
          :length => 1 - seeds[:length].to_f / (_n.clean_inner_tokens_text.size + seeds[:length]), #length of inner text in this node, too little = less
          :internal_nodes => seeds[:internal_nodes].to_f / (_n.internal_nodes_size + seeds[:internal_nodes] + seeds[:internal_nodes_buffer]), #number of nodes in this node, too many = less
          :distance_from_top => (1-(_rank.to_f / @nodes.size))**seeds[:distance_from_top].to_f, #how far this element is from the top of the page
          :title_match => ((content_node_ferret_index[_i]||0.0 + seeds[:title_match_buffer]) / 1+ + seeds[:title_match_buffer])**seeds[:title_match].to_f #ferret index score, search score with page title
          #:special_characters => (1 - (_n.inner_text.scan(/[^\s\302\240a-zA-Z]/).size.to_f / (_n.clean_inner_text.size+1)))**2 #number of special characters and numbers.. this is pretty cpu intensive!
        }
        o << {:node =>_n, :score => scores.values.inject(:*), :scores => scores}
      }
      
      o.sort!{|a,b| b[:score] <=> a[:score]}
      
      #o[0,1].each{|o2| pp [o2[:score], o2[:scores]]}
      #o[0,1].each{|o2| pp [refine_content_node(o2[:node]).clean_inner_text, o2[:score], o2[:scores]]}
            
      return o
    end
    
    def refine_content_node(node)
      node = node.dup
      
      #strip 'clutter'
      #i.children.each{|_n| pp _n.inner_text; pp _n.clean_inner_text.size}
      _min_size = 30
      node.children.each{|_n|
        if(_n.clean_inner_tokens_text.size < _min_size)
          _n.remove
        else; break; end
      }
      node.children.reverse.each{|_n|
        if(_n.clean_inner_tokens_text.size < _min_size)
          _n.remove
        else; break; end
      }
      node.search('*').each{|_n| _n.after(' ')}
      
      return node
    end
    
    
    def content_node_ferret_index
      @content_node_ferret_index ||= caluclate_content_node_ferret_index
    end
    def caluclate_content_node_ferret_index
      index = Ferret::Index::Index.new()
      index.field_infos.add_field(:id, :store => :yes)
      index.field_infos.add_field(:content, :store => :no, :boost => 1)


      @nodes.each_index{|_i|
        i=@nodes[_i]
        index << {
          :id => _i,
          :content => i.clean_inner_text,
        }
      }


      q=self.title.gsub(/[:()\[\]{}!+"~^\-|<>=*?\\]/,'') #remove special charcaters used by ferret query parser: http://www.davebalmain.com/api/classes/Ferret/QueryParser.html, http://www.regular-expressions.info/charclass.html
      s=index.search(q, :limit => @nodes.size)

      o=[]
      s.hits.each {|hit|
        _i = index[hit.doc][:id].to_i
        _n = @nodes[_i]
        _search_score = hit.score
        _search_normalised_score = hit.score/s.max_score
        #logger.info [_n.clean_inner_text, _search_score, _search_normalised_score].pretty_inspect
        o[_i] = _search_normalised_score
      }
      o
    end

  end


end





Nokogiri::XML::Node.class_eval {
  def clean_inner_text
    @clean_inner_text ||= Charles::Misc.normalize_string(inner_text)
  end
  def clean_inner_tokens_text
    @clean_inner_tokens_text ||= (
        Charles::Misc.string_to_clean_tokens_string(clean_inner_text)
      )
  end
  def internal_nodes_size
    @internal_nodes_size ||= search('*').size
  end
}


#https://github.com/cheald/pismo/blob/master/lib/pismo.rb
class Nokogiri::HTML::Document
  def get_the(search)
    self.search(search).first rescue nil
  end

  def match(queries = [])
    [].tap do |results|
      [*queries].each do |query|
        result = begin
          if query.is_a?(String)
            if el = self.search(query).first
              if el.name.downcase == "meta"
                el['content']
              else
                el.inner_text
              end
            end
          elsif query.is_a?(Array)
            query.last.call( self.search(query.first).first )
          end
        rescue
          nil
        end
        results << Charles::Misc.normalize_string(result) if result
      end
    end.compact
  end
end
