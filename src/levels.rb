class Level
  attr_reader :nr, :title, :levels, :song
  attr_accessor :minis_count
  def initialize(options = {})
    @nr = options[:nr] || 1
    @title = options[:title] || "-no title-"
    @song = options[:song]
    @minis_count = options[:minis_count]
    
    @start_logic = nil
    @game_logic = nil
    @status = :new
  end
  
  def new?;       @status == :new;  end
  def started?;   @status == :started;  end
  def finished?;  @status == :finished; end
  
  def start_song
    if @song
      @song.play(true)
      @song.volume = 0.3
    end
  end
    
  def start(objects)
    @start_logic.call(self, objects)  if @start_logic
    @status = :started
  end
  
  def update(ticks, objects)
    @game_logic.call(self, ticks, objects)
    @status = :finished if objects.size == 0 && @minis_count == 0
  end
  
  def on_update(&block)
    @game_logic = block
  end
  def on_start(&block)
    @start_logic = block
  end

  def self.setup_levels(options = {})
    @@space = options[:space]
    @@levels = Array.new
    
    ##########
    # LEVEL 1
    ##########
    level = Level.new(:nr => 1,:title => "First Encounter", :song => Song['22818__acclivity__Wind.ogg'], :minis_count => 10)
    level.on_update do |level, ticks, objects|
      if ticks % 130 == 0
        if level.minis_count > 0
          objects << Mini.new( :x => $screen.width, :y => 300, :mass => 3.0,
                               :speed => 5 + rand(6), :jump_power => 30+rand(100), :space => @@space)
          level.minis_count -= 1
        end
      elsif ticks % 60 == 0
        objects[rand(objects.size)].jump! rescue nil
      end
    end
    @@levels << level
    
    
    ##########
    # LEVEL 2
    ##########
    level = Level.new(:nr => 2, :title => "The Village", :song => Song['22818__acclivity__Wind.ogg'], :minis_count => 20)
    level.on_start do |level, objects|
      objects << WoodenHouse.new(:x => 700, :y => 300, :height => 1, :mass => 40, :space => @@space)
      objects << WoodenHouse.new(:x => 750, :y => 300, :height => 2, :mass => 40, :space => @@space)
      objects << WoodenHouse.new(:x => 800, :y => 300, :height => 1, :mass => 40, :space => @@space)
      objects << WoodenHouse.new(:x => 850, :y => 300, :height => 1, :mass => 40, :space => @@space)
      objects << WoodenHouse.new(:x => 880, :y => 300, :height => 2, :mass => 40, :space => @@space)
      objects << WoodenHouse.new(:x => 980, :y => 300, :height => 1, :mass => 40, :space => @@space)
    end    
    level.on_update do |level, ticks, objects|
      if ticks % 100 == 0  
        if level.minis_count > 0
          objects << Mini.new( :x => $screen.width, :y => 300, :mass => 3.0,
                              :speed => 12 + rand(10), :jump_power => 60+rand(130), :space => @@space)
          level.minis_count -= 1
        end
      end
      if ticks % 50 == 0
        objects[rand(objects.size)].jump! rescue nil
      end      
    end
    @@levels << level
    
    
    ##########
    # LEVEL 3
    ##########
    level = Level.new(:nr => 3, :title => "The Small Town", :song => Song['22818__acclivity__Wind.ogg'], :minis_count => 35)
    level.on_start do |level, objects|
      objects << WoodenHouse.new(:x => 400, :y => 300, :height => 2, :mass => 40, :space => @@space)      
      objects << WoodenHouse.new(:x => 440, :y => 300, :height => 3, :mass => 40, :space => @@space)
      objects << WoodenHouse.new(:x => 500, :y => 300, :height => 4, :mass => 40, :space => @@space)
      objects << WoodenHouse.new(:x => 630, :y => 300, :height => 1, :mass => 40, :space => @@space)
      objects << WoodenHouse.new(:x => 550, :y => 300, :height => 4, :mass => 40, :space => @@space)
      objects << Skyscraper.new(:x => 700, :y => 300, :height => 3, :mass => 70, :space => @@space)
      objects << Skyscraper.new(:x => 900, :y => 300, :height => 1, :mass => 70, :space => @@space)
      objects << Skyscraper.new(:x => 1000, :y => 300, :height => 2, :mass => 70, :space => @@space)
    end    
    level.on_update do |level, ticks, objects|
      if ticks % 70 == 0
        if level.minis_count > 0
          objects << Mini.new( :x => $screen.width, :y => 300, :mass => 3.0,
                              :speed => 10 + rand(10), :jump_power => 70+rand(140), :space => @@space)
          level.minis_count -= 1
        end        
      end
      if ticks % 40 == 0
        objects[rand(objects.size)].jump! rescue nil
      end      
    end
    @@levels << level

    ##########
    # LEVEL 4
    ##########
    level = Level.new(:nr => 4, :title => "The City", :song => Song['36734__sagetyrtle__citystreet3.ogg'], :minis_count => 40)
    level.on_start do |level, objects|
      objects << WoodenHouse.new(:x => 500, :y => 300, :height => 3, :mass => 40, :space => @@space)
      objects << Skyscraper.new(:x => 550, :y => 300, :height => 4, :mass => 40, :space => @@space)
      objects << Skyscraper.new(:x => 700, :y => 300, :height => 6, :mass => 70, :space => @@space)
      objects << Skyscraper.new(:x => 800, :y => 300, :height => 3, :mass => 70, :space => @@space)
      objects << Skyscraper.new(:x => 700, :y => 300, :height => 6, :mass => 70, :space => @@space)      
    end    
    level.on_update do |level, ticks, objects|
      if ticks % 70 == 0  
        if level.minis_count > 0
          objects << Mini.new( :x => $screen.width, :y => 300, :mass => 3.0,
                             :speed => 10 + rand(4), :jump_power => 70+rand(160), :space => @@space)
          level.minis_count -= 1
        end
      end
      if ticks % 40 == 0
        objects[rand(objects.size)].jump! rescue nil
      end      
    end
    @@levels << level

    ##########
    # LEVEL 5
    ##########
    level = Level.new(:nr => 5, :title => "The Metropolis", :song => Song['36734__sagetyrtle__citystreet3.ogg'], :minis_count => 60)
    level.on_start do |level, objects|
      objects << Skyscraper.new(:x => 350, :y => 300, :height => 10, :mass => 40, :space => @@space)
      objects << Skyscraper.new(:x => 500, :y => 300, :height => 3, :mass => 40, :space => @@space)
      objects << Skyscraper.new(:x => 550, :y => 300, :height => 4, :mass => 40, :space => @@space)
      objects << Skyscraper.new(:x => 700, :y => 300, :height => 3, :mass => 70, :space => @@space)
      objects << Skyscraper.new(:x => 750, :y => 300, :height => 4, :mass => 70, :space => @@space)
      #objects << Skyscraper.new(:x => 800, :y => 300, :height => 9, :mass => 70, :space => @@space)
      objects << Skyscraper.new(:x => 900, :y => 300, :height => 5, :mass => 70, :space => @@space)
      #objects << Skyscraper.new(:x => 1000, :y => 300, :height => 7, :mass => 70, :space => @@space)
    end    
    level.on_update do |level, ticks, objects|
      if ticks % 50 == 0  
        if level.minis_count > 0
          objects << Mini.new( :x => $screen.width, :y => 300, :mass => 3.0,
                              :speed => 10 + rand(4), :jump_power => 80+rand(200), :space => @@space)
          level.minis_count -= 1 rescue nil
        end
      end
      if ticks % 40 == 0
        objects[rand(objects.size)].jump!
      end      
    end
    @@levels << level


    @@levels
  end
end


    
