class Thing
  
  
  attr_accessor :name, :last_method

  def initialize(name)
    @name = name
    @last_method = nil
  end
  
  [:is_a, :is_not_a, :is_the].each do |method_name|
    define_method(method_name) do
      @last_method = {type: method_name, exec: 0}
      self
    end    
  end   

  def has(number)
    @last_method = {type: :has, exec: 0, has_params_number: number}
    self
  end

  def can(*args, &block)
    @last_method = {type: :can, exec: 0}
    self
  end

  alias having has
  alias with has
  alias being_the is_the
  alias and_the is_the

  def method_missing(attr, *args, &block)
    if block_given?
      yield
    else
     "no block"
    end

    return instance_variable_get("@#{attr.to_s.sub('?','')}") if @last_method[:exec] == 1

    case @last_method[:type]
  
    when :is_a
      instance_variable_set("@#{attr}", true)       
      @last_method[:exec] = 1

    when :is_not_a
      instance_variable_set("@#{attr}", false)
      @last_method[:exec] = 1

    when :is_the
      prop = @last_method[:property] 
      if prop
        instance_variable_set("@#{prop}", attr)
        @last_method[:exec] = 1
      else 
        @last_method[:property] = attr;
      end 

    when :has
      has_number = @last_method[:has_params_number]
        
      value = if has_number > 1
         ThingArray.new(has_number) { Thing.new("#{attr}") }
      elsif has_number == 1
        Thing.new("#{attr}")
      end
  
      instance_variable_set("@#{attr}", value)
      @last_method[:exec] = 1
      return value
    end

    self
  end

end

class ThingArray < Array
  def each(*_args, &block)
    to_a.each do |element|
      element.instance_eval(&block)
    end
  end
end

jane = Thing.new('jane_1')


#jane.has(2).arms.each{ having(1).hand.having(5).fingers }
#p jane.arms

#jane.is_the.parent_of.joe
jane.has(1).head.having(2).eyes.each { being_the.color.blue.with(1).pupil.being_the.color.black }
p jane.head.eyes

