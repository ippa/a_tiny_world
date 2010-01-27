#!/usr/bin/env ruby
$stderr.sync = $stdout.sync = true
ROOT_PATH = File.dirname(File.expand_path(__FILE__))
$:.unshift(File.join(ROOT_PATH, "lib" ))
$:.unshift(File.join(ROOT_PATH, "src" ))

## if RUBY_PLATFORM =~ /djgpp|(cyg|ms|bcc)win|mingw
#$:.unshift(File.join(ROOT_PATH, "lib", "win32" ))   if RUBY_PLATFORM.downcase.include?("win32")
#$:.unshift(File.join(ROOT_PATH, "lib", "linux" ))   if RUBY_PLATFORM.downcase.include?("linux")
#$:.unshift(File.join(ROOT_PATH, "lib", "osx" ))     if RUBY_PLATFORM.downcase.include?("darwin")
  
require 'rubygems'
require 'chipmunk'
require 'gosu'
require 'texplay'

include Gosu
include CP

require 'gosu_fpscounter.rb'
require 'gosu_autoload'
require 'gosu_game_common'
require 'chipmunk_object.rb'
require 'game_objects.rb'
require 'buildings.rb'
require 'levels.rb'

class GameWindow < Gosu::Window
  attr_reader :width, :height
  def initialize
    @substeps = 6
    @width, @height = 1024, 300
    full_screen = ARGV.include?("--fullscreen")
    $screen = super(@width, @height, full_screen)
    $zoom = 1 # Global zoomfactor, affects all image.draw-calls

    #puts "width: #{screen_width} height: #{screen_height}"
    #puts "Ruby: #{RUBY_VERSION}"
		
		Image.autoload_dirs = [".", File.join(ROOT_PATH, "gfx")]
		Tile.autoload_dirs = [".", File.join(ROOT_PATH, "gfx")]
    Sample.autoload_dirs = [".", File.join(ROOT_PATH, "sounds")]
    Song.autoload_dirs = [".", File.join(ROOT_PATH, "sounds")]
    Font.autoload_dirs = [".", File.join(ROOT_PATH, "fonts")]
  
    # Chipmunk setup
    @dt = (1.0/60.0)
		@space = CP::Space.new
    @space.damping = 0.9
		@space.gravity = CP::Vec2.new(0, 8.0)
        
    @stats_font = Font.new($screen, File.join(ROOT_PATH, "fonts", "imagine_font.ttf"), 15)
    @text_font = Font.new($screen, File.join(ROOT_PATH, "fonts", "TravelingTypewriter.ttf"), 30)
    @level_title_font = Font.new($screen, File.join(ROOT_PATH, "fonts", "TravelingTypewriter.ttf"), 40)
    
    @objects = Array.new    
    @ground = Ground.new(:x => 0, :y => 0, :space => @space)
    @player = Player.new(:x => 100, :y => 300, :mass => 20, :space => @space)
    
    @levels = Level.setup_levels(:space => @space)
    @level = @levels.shift
    @level.start_song
    
    #
    # GROUND vs MINI
    #
    @space.add_collision_func(:ground, :mini) do |ground, mini|
      if mini.obj.body.v.x > 100 && mini.obj.body.p.y < $screen.height
        mini.obj.slam!
        @player.score += mini.obj.power * 2
      else
        mini.obj.land!
      end
    
      true
    end

    #
    # OUTSOLE vs BUILDING
    #
    @space.add_collision_func(:outsole, :building) do |outsole, building|
      if outsole.obj.body.v.y > building.obj.health
        
        if building.obj.crush!(building)  # returns true if totally destroyd
          @player.score += building.obj.health
        end
          
        outsole.obj.body.v.y -= building.obj.health    
        3.times { |nr| outsole.obj.image.paint { color [50,50,50,255]; pixel (building.obj.x - outsole.obj.x) - rand(20), 300-rand(nr) } }
      end
      true
    end

    #
    # OUTSOLE vs MINI
    #
    @space.add_collision_func(:outsole, :mini) do |outsole, mini|
      
      ## Mini on ground and foot on it's way down
      if mini.obj.status == :on_ground && outsole.obj.body.v.y > 0
        mini.obj.crush!
        10.times { |nr| outsole.obj.image.paint { color :red; pixel (mini.obj.x - outsole.obj.x) - rand(4), 300-rand(nr*2) } }
        @player.score += mini.obj.power
      end
      true
    end

    #
    # OUTSOLE vs GROUND
    #
    @space.add_collision_func(:outsole, :ground) do |outsole, ground|
      if outsole.obj.body.v.y > 20
        Sample['16793__pushtobreak__Earth1.ogg'].play(outsole.obj.body.v.y * 0.005)
      end
    end
    
    #
    # LEG vs MINI
    #
    @space.add_collision_func(:leg, :mini) do |leg, mini|
      Sample['20279__Koops__Apple_Crunch_16.wav'].play(0.8, 1.0 + rand(10)/10.0)      
      ##leg.obj.image.paint { splice(mini.obj.biting_image, (mini.obj.x - leg.obj.x), (leg.obj.image.height - leg.obj.y) + mini.obj.y-9) }
      leg.obj.image.paint { color [0,0,0,0]; circle (mini.obj.x-leg.obj.x), (leg.obj.image.height-leg.obj.y)+mini.obj.y-9, 5+rand(5) }      
      10.times { |nr| leg.obj.image.paint { color :red; pixel (mini.obj.x-leg.obj.x)+rand(5), (leg.obj.image.height - leg.obj.y) + mini.obj.y-9 + rand(8) } }
      @player.health -= mini.obj.power
      @player.score -= mini.obj.power * 5
      mini.obj.die!
      true
    end    

    self.caption = "A Tiny World! RubyWeekend #3 entry by ippa @ #freenode"
    @background = Image["clear_blue_skies.png"]  
    @ticks = 0
    @fps_counter = FPSCounter.new
	end
	
	def update
    @fps_counter.register_tick
    @ticks = @ticks + 1
    
    @player.update(@ticks)
    @objects.reject! { |object| object.update(@ticks) == false }
    @level.update(@ticks, @objects) if @level.started?
    @substeps.times { @space.step(@dt) }
    
    if @player.dead?
      @level_title_font.draw_rel("Game Over, press Enter to try again!", $screen.width/2, $screen.height/2-40, 21, 0.5, 0.5)
    end
    
    handle_keys
		#self.caption = "A Tiny World [objs: #{@objects.size} - left: #{@level.minis_count} - framerate: #{@fps_counter.fps}] - Health: #{@player.health.to_i} - Status: #{@player.status.to_s} - #{@player.body.p.x}"
	end

	def draw
    @background.draw(0,0,0)
    @player.draw(0, 0)
    @objects.each { |object| object.draw(object.x, object.y) }   
    @stats_font.draw("Health: #{@player.health}    Score: #{@player.score}", 700, 5, 20)
    
    if @level.new?
      @level_title_font.draw_rel(@level.title, $screen.width/2, $screen.height/2-40, 21, 0.5, 0.5)
      @text_font.draw_rel("Press Enter to start!  Move legs with Arrow keys, kick with Space.", $screen.width/2, $screen.height/2, 20, 0.5, 0.5)
    end    
    if @level.finished?
      if @level.nr==5
        @text_font.draw_rel("Game finished! Your final Score: #{@player.score}", $screen.width/2, $screen.height/2, 20, 0.5, 0.5)
      else
        @text_font.draw_rel("Level finished!  Press Enter to continue.", $screen.width/2, $screen.height/2, 20, 0.5, 0.5)
      end
    end    
	end		
  
  def handle_keys
    if !@player.dead?
      @player.left      if button_down? Button::KbLeft
      @player.right     if button_down? Button::KbRight
      @player.up        if button_down? Button::KbUp
      @player.down      if button_down? Button::KbDown
      @player.kick      if button_down? Button::KbSpace
      @player.stop_step if !button_down? Button::KbRight
    end
    
    close					    if button_down? Button::KbEscape		     
    
    if @level.new? && button_down?(Button::KbReturn)    
      @level.start(@objects)
    end
    
    if @level.finished? && button_down?(Button::KbReturn)
      @player.reset_legs
      @level = @levels.shift
      @level.start_song
      sleep(1)
    end
    
    if @player.dead? && button_down?(Button::KbReturn)
      @objects.each { |object|  object.remove_shapes_from_space(@space) }
      @objects = []
      
      @player.score = 0
      @player.health = 100
      @player.reset_graphics
      @player.reset_legs
      
      @levels = Level.setup_levels(:space => @space)
      @level = @levels.shift
      @level.start_song
      sleep(1)
    end

    if button_down?(Button::KbJ)
      @objects.each { |object|  object.remove_shapes_from_space(@space) }
      @objects = []
      sleep(1)

      @player.reset_legs
      @level = @levels.shift
      @level.start_song
    end
    
    #@objects[rand(@objects.size)].jump! if button_down? Kb0
    ## @objects << Particle.new(@player.x, @player.y, "smoke.png")    if button_down? Button::KbA
  end
    
end

GameWindow.new.show
