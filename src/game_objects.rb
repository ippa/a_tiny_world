class Player
  attr_accessor :status, :health, :score
  attr_reader :status, :punch, :value, :image
	attr_reader :shape, :body, :motor
  attr_reader :leg1, :leg2

  def initialize(options = {})		
		@x = options[:x] || 0.0
		@y = options[:y] || $screen.height
		@mass = options[:mass] || 0	
    @inertia = options[:inertia] || Float::INFINITY # Inertia is the resistance an object has to a change in its state of motion.)
    
    @body = CP::Body.new(@mass , @inertia)
    @body.pos = vec2(@x, @y)
    @body.angle = 0    
  
    options[:owner] = self
    @leg1 = Leg.new(options)
    @leg2 = Leg.new(options)
    reset_legs
    
    @score = 0  
    @health = 100
    @max_space_between_legs = 250
	end

  def x; @body.pos.x; end
	def y; @body.pos.y; end
  def space_between_legs; @leg2.body.pos.x - @leg1.body.pos.x; end
  def dead?; @health <= 0; end
  
  def reset_legs
    @leg1.body.pos = vec2(100,$screen.height)
    @leg2.body.pos = vec2(230,$screen.height)
  end
  
  def reset_graphics
    @leg1.load_tiles
    @leg2.load_tiles
  end

    
  def left;   @leg2.left;  end
  def right
    if @status == :stepping || (space_between_legs >= @max_space_between_legs)
      @status = :stepping
      @leg1.right
    else
      @leg2.right
    end
  end
  def up;   @leg2.up; end
  def down; @leg2.down; end  
  def kick; @leg2.kick; end
  def stop_step
    @status = :normal
  end
  
  def update(ticks)    
    [@leg1, @leg2].each do |leg|
      leg.body.vel.y = 0 if leg.body.pos.y < 50
      leg.body.vel.x = 0 if leg.body.pos.x < 1
    end

    if space_between_legs >= @max_space_between_legs
      leg2.body.vel.x = 0  if leg2.body.vel.x > 0
      leg1.body.vel.x = 0  if leg2.body.vel.x < 0
      #@status = :default
    end

    true
  end
 
	def draw(x, y)
    @leg1.draw(@leg1.x, @leg1.y)
    @leg2.draw(@leg2.x, @leg2.y)
		self
	end	 
end


class Leg < ChipmunkObject
  attr_accessor :image
  def initialize(options = {})		
    super(options)
    @owner = options[:owner]
    # shape.e: Elasticity of the shape. 0 = no bounce, 1 = perfect bounce      
    # shape.u: Friction coefficient. 0 = no friction
    #shape_array = [CP::Vec2.new(0, 0), CP::Vec2.new(0, 300), CP::Vec2.new(100, 300), CP::Vec2.new(100, 0)]
    
    shape_array = [CP::Vec2.new(5, 0), CP::Vec2.new(5, 300), CP::Vec2.new(50, 300), CP::Vec2.new(50, 0)]
    shape = CP::Shape::Poly.new(@body, shape_array, vec2(0,-300-8))
    shape.collision_type = :leg
    shape.layers = 0xFFFFFFFF
		shape.e = 0.5
		shape.u = 0
    shape.obj = self
    @shapes << shape
    
    shape_array = [CP::Vec2.new(0, 0), CP::Vec2.new(0, 45), CP::Vec2.new(100, 45), CP::Vec2.new(100, 0)]
    shape2 = CP::Shape::Poly.new(@body, shape_array, vec2(0,-45-8))
    shape2.collision_type = :foot
    shape.layers = 0xFFFFFFFF
		shape2.e = 0.5
		shape2.u = 0
    shape2.obj = self
    @shapes << shape2

    shape_array = [CP::Vec2.new(0, 0), CP::Vec2.new(0, 8), CP::Vec2.new(98, 8), CP::Vec2.new(98, 0)]
    shape3 = CP::Shape::Poly.new(@body, shape_array, vec2(1,-8))
    shape3.collision_type = :outsole
    shape.layers = 0xFFFFFFFF
		shape3.e = 0.5
		shape3.u = 1
    shape3.obj = self
    @shapes << shape3

    load_tiles
    
    add_shapes_to_space(@space)
  end
  
  def load_tiles
    @image = Gosu::Image.new($screen, File.join(ROOT_PATH, "gfx", "leg2.png"))
  end
  

  def left;   @body.vel.x = -20; end
  def right;  @body.vel.x = 20;  end
  def up;     @body.vel.y = -20; end
  def kick;   @body.vel.x = 200; end
  #def down;   @body.vel.y = +20; end
  
  def draw(x,y)
    @image.draw_rot(x,y-@image.height,10,@body.angle.radians_to_gosu, 0, 0, $zoom,$zoom)
  end
end
  
class Mini < ChipmunkObject
  attr_reader :status, :image, :biting_image, :power
  attr_accessor :health

  def initialize(options = {})		
    super(options)
    
    @speed = options[:speed] || 4
    @jump_power = options[:jump_power] || 10
    @power = options[:power] || 10
    @health = options[:health] || 10
    
    shape_array = [CP::Vec2.new(0, 0), CP::Vec2.new(0, 9), CP::Vec2.new(7, 9), CP::Vec2.new(7, 0)]
    shape = CP::Shape::Poly.new(@body, shape_array, vec2(0,-9))
    shape.collision_type = :mini
    shape.layers = 0x00FF0000
		shape.e = 0.9  # e: Elasticity of the shape. 0 = no bounce, 1 = perfect bounce      
		shape.u = 0.4  # u: Friction coefficient. 0 = no friction
    shape.obj = self
    @shapes << shape
    
    add_shapes_to_space(@space)

    @player_running = Gosu::Image.load_tiles($screen, File.join(ROOT_PATH, "gfx", "player_running.bmp"), 7, 9, true)
    @player_jumping = Gosu::Image.load_tiles($screen, File.join(ROOT_PATH, "gfx", "player_jumping.bmp"), 7, 9, true)
    @player_crushed = Gosu::Image.load_tiles($screen, File.join(ROOT_PATH, "gfx", "player_crushed.bmp"), 7, 9, true)
    @player_misc = Gosu::Image.load_tiles($screen, File.join(ROOT_PATH, "gfx", "player_misc.bmp"), 7, 9, true)
    @image = @player_misc.first ## First tile is a standing-still image
    use_tiles(@player_running, :random_start => true)
  
    @biting_image = @player_misc[1]  

		@status = :default
    @direction = :left
    @health = 40
    @value = 40
    @ticks_per_image = 3
  end
	
  def update(ticks)
    if ticks % @ticks_per_image == 0
      next_image!
    end
      
    if alive?
      @shapes.first.surface_v = vec2(@speed, 0) if @direction == :left
      #@body.vel.x = -@speed if @direction == :left
    end
      
    return alive?
  end
  
	def left!
    @direction = :left
    @body.vel.x = -@speed
  end
  
  def right!
    if @status == :jumping
      @body.apply_impulse(vec2(100,0), vec2(0.0, 0.0)) if @body.vel.x.abs < 40
    else
      @shape.surface_v = vec2(-@speed, 0)
      @status = :moving_right
    end
    @direction = :right
	end

	def stop!
		@shape.surface_v = vec2(0,0)
    @image = @player_misc.first
    @tiles_index = 0
    @status = :stopped
	end

  def dying?; @status == :dying; end
  def dead?;  @status == :dead; end
  def alive?; @status != :dead; end
    
	def jump!
    if alive? && !dying? && (@status != :jumping)
      @body.apply_impulse(vec2(-rand(100), -@jump_power), vec2(0.0, 0.0))
      #@body.apply_impulse(vec2(0, -@jump_power), vec2(0.0, 0.0))
      @status = :jumping
      
      use_tiles(@player_jumping)
      @ticks_per_image = 7
      Sample['77__plagasul__JuOb.wav'].play(0.2, 1.0 + rand(10)/10.0)
    end
  end

  def use_tiles(tiles, options = {})
    if @tiles != tiles
      @tiles = tiles
      
      if options[:random_start]
        @tile_index = rand(@tiles.size)
      else
        @tile_index = 0
      end
      @tiles_size = @tiles.size
    end
  end

	def land!
    if @status != :on_ground && alive? && !dying?
      @status = :on_ground
      use_tiles(@player_running)
      @ticks_per_image = 3
      #puts "Landed!"; p @body.vel
    end
  end
  
  def die!
    if alive?
      @status = :dead
      remove_shapes_from_space(@space)
    end
  end

  def crush!
    if alive? && !dying?
      use_tiles(@player_crushed)
      @ticks_per_image = 1
      #puts "Crushed Mini: #{@status.to_s}"; p @body.vel
      remove_shapes_from_space(@space)
      @status = :dying
      Sample['43589__Donalfonso__Squash.wav'].play(0.6,1 + rand(20)/10.0)
    end
  end
  
  def slam!
    if alive? && !dying?
      use_tiles(@player_jumping)
      @body.moment = 0  ## Can rotate!
      #puts "Slammed Mini: #{@status.to_s}"; p @body.vel
      remove_shapes_from_space(@space)
      @status = :dying
      Sample['8838__Churd_Tzu__water_bottle_snare_15_bonk_.wav'].play(0.5,1 + rand(10)/10.0)
    end
  end
	
  def next_image!
    if alive?
      @image = @tiles[@tile_index]
      @tile_index = @tile_index + 1
      
      if @tile_index >= @tiles_size
        die!  if dying?
        @tile_index = 0 
      end
    end
  end
end

class Ground < ChipmunkObject
	attr_reader :shapes, :body

  def initialize(options = {})
    super(options)
   
    #shape_array = [Vec2.new(0, 0), Vec2.new(0, 300), Vec2.new(2000, 300), Vec2.new(2000, 0)]
    #shape = CP::Shape::Poly.new(@body, shape_array, vec2(0, 0))
    
    thickness = 5
    width = $screen.width + thickness
    height = $screen.height + thickness

    segments = [
      [vec2(0, 0), vec2(0, height)],
      [vec2(width, 0), vec2(width, height)],
      [vec2(0, height), vec2(width, height)]
    ]
    
    segments.each do |from, to|
      shape = Shape::Segment.new(@body, from, to, thickness)
      shape.collision_type = :ground
      shape.layers = 0xFFFFFFFF
      shape.e = 0.5  # e: Elasticity of the shape. 0 = no bounce, 1 = perfect bounce      
      shape.u = 1  # u: Friction coefficient. 0 = no friction
      @shapes << shape
    end
    
    add_shapes_to_space(@space, {:static => true})
	end

	def x; @body.pos.x; end
	def y; @body.pos.y; end
end




    #shape_array = [CP::Vec2.new(0, 0), CP::Vec2.new(0, 300), CP::Vec2.new(100, 300), CP::Vec2.new(100, 0)]
    #@shape = CP::Shape::Poly.new(@body, shape_array, vec2(0,0))
    #@shape.collision_type = :player
		#@shape.e = 0.5 # e: Elasticity of the shape. 0 = no bounce, 1 = perfect bounce      
		#@shape.u = 0.3  # u: Friction coefficient. 0 = no friction



    #@image.draw_rot(x,y-@image.height,10,@body.angle.radians_to_gosu, 0.5, 0.5, $zoom, $zoom)
    #puts "#{self.class.to_s} @ #{x.to_i}/#{y.to_i}" rescue nil
    #@leg.draw(x,y-@image.height,10,$zoom, $zoom)    
    ##@image.draw_rot(x,y-@image.height,10,@body.angle.radians_to_gosu,0.5,0.5,(@direction == :left) ? -$zoom : $zoom,$zoom)
