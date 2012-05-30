module Charles
  module Images
    def image
      images && images.first
    end
    def images
      @images ||= calculate_images
    end
    def calculate_images
      _node = self.content_node
      return unless _node
      #logger.info _node.pretty_inspect
  
      (_node.ancestors.size.to_f/2).round.times do
        o=self.calculate_image_from_node(_node)
        #logger.info o.pretty_inspect
        return o if o
        _node = _node.parent
      end
  
      return []
    end
    def calculate_image_from_node(_node)
      _imgs = _node.search('img')
  
      i=URI.parse(@options[:url])
      if !_imgs.empty? && _imgs.size < 50 #sanity check if more than 50 images...
        o=[]
        _imgs.each do |_img|
          next unless _img.attr('src')
          begin
            _u = (i + _img.attr('src')).to_s
          rescue StandardError => e
            logger.info "Error #{e}: #{i} + #{_img.attr('src')}"
            next
          end
          o << _u
        end
        return o
      end
  
      return nil
    end
    
    def filtered_images
      _max_proportion = 2.5
      _min_area = 88*88
      _filtered_images = []
      _images = self.images.dup
      _images.each{|url|
        data = get_image(url)
        next unless data
        size = ImageSize.new(data).get_size
        if(size[0] * size[1] > _min_area &&
          size[0].to_f/size[1] < _max_proportion &&
          size[1].to_f/size[0] < _max_proportion)
          _filtered_images << {:url => url, :data => data, :width => size[0], :height => size[1]}
        end
      }
      return _filtered_images
    end
    
    def get_image(url)
      _cache_key = "get_image(#{url})"
      begin
        Charles.file_cache.fetch(_cache_key) {
          body = mechanize_agent.get(url, [], URI.parse(@options[:url])).body
          body.size < 900000 ? body : nil
        }
      rescue StandardError, Timeout::Error
        Charles.file_cache.write(_cache_key, nil, :expires_in => 1.hour)
      end
    end
  end
end

    