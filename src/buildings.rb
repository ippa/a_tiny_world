class Building
  attr_reader :blocks, :x, :y
  
  def initialize(options = {})
    @height = options[:height] || 4
    @x = options[:x]
    @y = options[:y] || $screen.height
    @block_height = options[:block_height] || 20
    @blocks = []
  end  

  def remove_shapes_from_space(space)
    @blocks.each { |block| block.remove_shapes_from_space(space) }
  end
  
  def jump!
    false
  end

  ## Return true if building still contains blocks
  def update(ticks)
    @blocks.collect { |block| block.update(ticks) }.include?(true)
  end
  
  def draw(x,y)
    @blocks.each { |block| block.draw(block.x, block.y); }
  end
end

class BuildingBlock < ChipmunkObject
  attr_reader :status, :image
  attr_accessor :health

  def initialize(options = {})		
    super(options)
    @health = options[:health] || 50
    @filename = options[:filename]
    @sample= options[:sample]
    
    @shape_arrays = [
      [vec2(0, 0), vec2(0, 20), vec2(32, 20), vec2(32, 0)],
      [vec2(0, 10), vec2(0, 20), vec2(32, 20), vec2(32, 10)],
    ]
    
    @shape_arrays.each do |shape_array|
      shape = CP::Shape::Poly.new(@body, shape_array, vec2(0,-20))
      shape.collision_type = :building
      shape.e = 0.2 # e: Elasticity of the shape. 0 = no bounce, 1 = perfect bounce      
      shape.u = 8   # u: Friction coefficient. 0 = no friction
      shape.layers = 0xFF000000
      shape.obj = self
      @shapes << shape
    end
    
    add_shapes_to_space(@space)

    @tiles = Gosu::Image.load_tiles($screen, File.join(ROOT_PATH, "gfx", @filename), 30, 21, true)
    @image = @tiles[rand(4)]
		@status = :default
    @ticks_per_image = 3
  end

  def alive?
    @status == :default || @status == :first_crush
  end
  
  def crush!(shape)
    @sample.play(0.6,1 + rand(20)/10.0)
    if @status == :default
      @image = @tiles[4]
      @status = :first_crush
      @space.remove_shape(shape)
    elsif @status == :first_crush
      @image = @tiles[5]
      @space.remove_shape(shape)
      @status = :second_crush
      return true
    end
    return false
	end
  def update(ticks)
    return alive?
  end
end


class WoodenHouse < Building
  def initialize(options = {})
    super(options)
    
    @height.times do |nr|
      @blocks << BuildingBlock.new(:x => @x, :y => (@y-(nr*@block_height)),
                                  :health => 30,
                                  :mass => options[:mass], 
                                  :space => options[:space],
                                  :filename => "woodenhouse.bmp",
                                  :sample => Sample["66780__kevinkace__Crate_Break_4.wav"]
                                  )
    end
  end
end


class Skyscraper < Building
  def initialize(options = {})
    super(options)
    
    @height.times do |nr|
      @blocks << BuildingBlock.new(:x => @x, :y => (@y-(nr*@block_height)),
                                  :health => 60,
                                  :mass => options[:mass], 
                                  :space => options[:space],
                                  :filename => "skyscraper.bmp",
                                  :sample => Sample['33629__themfish__bulb_smash.ogg']
                                  )
    end
  end
end

  
