class Thing
    
  attr_accessor :name, :state

  def initialize(name)
    @name = name
    @properties = {}
  end
  
  [:is_a, :is_not_a].each do |method_name|
    define_method(method_name) do
      @state = { type: method_name, value: method_name == :is_a } 
      self
    end    
  end   

  def is_the
    @state = { type: :is_the } 
    self
  end

  def has(number)
    @state = { type: :has, has_params_number: number } 
    self
  end

  def can(*args, &block)
    @state = { type: :can } 
    self
  end

  alias having has
  alias with has
  alias being_the is_the
  alias and_the is_the

  def exec_last_command(attr, args)
    if /\?$/.match(attr)
        attr = attr.to_s.sub('?','').to_sym
    end

    if @properties.key?(attr)
      value = @properties[attr]
      
      if value.is_a? Proc
        instance_exec(args, &value)
        value = nil
      end      

      @state = nil
      value
    end
  end

  def method_missing(attr, *args, &block)

    res = exec_last_command(attr, args)
    return res unless @state
    
    case @state[:type]
  
    when :is_a, :is_not_a
      @properties[attr] = @state[:value]

    when :is_the
      prop = @properties[:attr_name] 
      if prop
        @properties[prop] = attr.to_s 
        @properties[:attr_name] = nil
      else 
        @properties[:attr_name] = attr
      end 

    when :has
      has_number = @state[:has_params_number]
      value = if has_number > 1
         ThingArray.new(has_number) { Thing.new("#{attr}") }
      elsif has_number == 1
        Thing.new("#{attr}")
      end
      @properties[attr] = value
    
    when :can
      @properties[attr] = block
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

jane.is_not_a.person
jane.is_a.person
#jane.is_the.parent_of.joe
#p jane.parent_of
p jane.person?
exit

#jane.has(2).arms.each{ having(1).hand.having(5).fingers }
#p jane.arms.first.hand.fingers.size

#jane.has(1).head.having(2).eyes.each { being_the.color.blue.with(1).pupil.being_the.color.black }
#p jane.head.eyes[0]

jane.can.speak('spoke') do |phrase|
  p "#{@name} says: #{phrase}"
end

jane.speak("hello")
#jane.last_method[:methods][:speak]