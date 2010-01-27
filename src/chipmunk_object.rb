#
# Basic ChipmunkObject template, creates a body etc.. default gosu draw()
#
class ChipmunkObject
  attr_reader :shapes, :body
  
  def initialize(options = {})		
		@x = options[:x] || 0.0
		@y = options[:y] || 0.0
		@mass = options[:mass] || Float::MAX
    @inertia = options[:inertia] || Float::INFINITY rescue 999999999999.9
    @space = options[:space] || $SPACE || nil
    
    @body = CP::Body.new(@mass , @inertia)
    @body.p = vec2(@x, @y)
    @body.a = 0
    @shapes = Array.new
  end
  
  def add_shapes_to_space(space, options = {})
    return  if space == nil
    
    if options[:static]
      #puts "Adding #{self.class.to_s} as static!"      
      @shapes.each { |shape| space.add_static_shape(shape) }
    else
      space.add_body(@body)
      @shapes.each { |shape| space.add_shape(shape) }
    end
  end

  def remove_shapes_from_space(space, options = {})
    return  if space == nil
    
    if options[:static]
      #puts "Removing #{self.class.to_s} as static!"      
      @shapes.each { |shape| space.remove_static_shape(shape) }
    else
      space.remove_body(@body)
      @shapes.each { |shape| space.remove_shape(shape) }
    end
  end

  def x; @body.p.x; end
	def y; @body.p.y; end

  def left; @body.apply_impulse(vec2(-200,0), vec2(0.0, 0.0)); end
  def right;@body.apply_impulse(vec2(200,0), vec2(0.0, 0.0)); end
  def up;   @body.apply_impulse(vec2(0,-200), vec2(0.0, 0.0)); end
  def down; @body.apply_impulse(vec2(0,200), vec2(0.0, 0.0)); end
  
	def draw(x=nil, y=nil)
    x = @body.p.x if x==nil
    y = @body.p.y if y==nil    		
    @image.draw_rot(x,y-@image.height,10,0, 0, 0, $zoom, $zoom)
		self
	end	   
end
