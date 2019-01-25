class Thing
  
  
  attr_accessor :name, :last_method, :obj_parts, :has_params_number, :childs

  def initialize(name)
    @name = name
    @obj_parts = []
    @last_method = nil
  end
  
  THING_METHODS = [:is_a, :is_not_a, :is_the]
   

  THING_METHODS.each do |method_name|
    
    define_method(method_name) do
      @last_method = method_name
      self
    end    
  end   

  [:has, :having].each do |method_name|
  
    define_method(method_name) do |number|
        @last_method = method_name
        @has_params_number = number
        self
    end 
  end

  def method_missing(attr, *args, &block)
    p "attr: #{attr} #{args} #{block_given?}"
    if block_given?
      yield
    else
     "no block"
    end
    return instance_variable_get("@#{attr.to_s.sub('?','')}") if @last_method.nil? || attr.to_s.end_with?("?") 
    
    @obj_parts << attr


    case @last_method
    when :is_a
      instance_variable_set("@#{attr}", true) 
      @obj_parts = []

    when :is_not_a
      instance_variable_set("@#{attr}", false) 
      @obj_parts = []

    when :is_the
      if @obj_parts.size == 2
        instance_variable_set("@#{@obj_parts[0]}", @obj_parts[1])
        @obj_parts = []
        
      end 

    when :has
      if @obj_parts.size == 1
        #p "has: #{attr} number: #{@has_params_number}"
        
        if @has_params_number > 1
          instance_variable_set("@#{attr}", Array.new(@has_params_number) { Thing.new("obj with #{attr}") })
        
        elsif @has_params_number == 1
          instance_variable_set("@#{attr}", Thing.new("obj with one") )
        end
        @obj_parts = []
        return instance_variable_get("@#{attr}")
        
      end 

    when :having
      if @obj_parts.size == 1

        if @has_params_number > 1
          instance_variable_set("@#{attr}", Array.new(@has_params_number) { Thing.new("obj with #{attr}") })
        
        elsif @has_params_number == 1
          instance_variable_set("@#{attr}", Thing.new("obj with one") )
        end
        @obj_parts = []
        return instance_variable_get("@#{attr}")
      end 

    end

    @last_method = nil if @obj_parts.empty?

    self
  end

end

jane = Thing.new('jane_1')


#jane.is_not_a.person; p jane.person?

#jane.is_the.parent_of.joe; p jane.parent_of

#jane.has(2).legs
#p jane.legs.first.is_a?(Thing)


#jane.has(2).arms.each { p "111" }
#jane.has(2).arms.each { having(1).hand.having(5).fingers }

#p jane.arms.first.hand

jane.has(2).arms.each{ |th| th.having(1).hand.having(5).fingers; p th }