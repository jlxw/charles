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
  
      (_node.ancestors.size/2).times do
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
  end
end

    