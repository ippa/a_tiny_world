require 'ctexplay'
require 'gosu'

module TexPlay
    TEXPLAY_VERSION = "0.1.4.6"
end

# monkey patching the Gosu::Image class to add image manipulation functionality
module Gosu
    class Image

        # bring in the TexPlay image manipulation methods
        include TexPlay
        
        class << self 
            alias_method :new_prev, :new
            
            def new(*args, &block)

                # invoke old behaviour
                obj = new_prev(*args, &block)

                # refresh the TexPlay image cache
                if obj.width <= (TexPlay::TP_MAX_QUAD_SIZE - 2) &&
                        obj.height <= (TexPlay::TP_MAX_QUAD_SIZE - 2) && obj.quad_cached? then
                    
                    obj.refresh_cache
                end

                # return the new image
                obj
            end
        end
    end
end
