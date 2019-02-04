
##---------------------------------------
class Thing
  def method_missing(m, *args, &block)
    puts m
    self
  end

  def call_methods(methods)
    methods.split('.').inject(self) do |obj, method|
      obj.send method
    end
  end  
end

object = Thing.new
object.call_methods 'aaa.bbb.ccc'


##----------------------------------------------
class Test
  define_method :each do |&b|

    p b
    b.call
  end
end

Test.new.each {
  puts self
}


#---------------------------------------------------
module A
  class << self
    def mymethod(arg1, arg2, &block)
      x = 1
      puts "arg1:#{arg1}"
      puts "arg2:#{arg2}"
      
      block.call(self)
    end
  end
end

A.mymethod("a","b") do 
  puts self
end