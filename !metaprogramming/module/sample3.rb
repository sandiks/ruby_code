module A
  def method1()  
    puts "method1 say hi"
  end
end

class B
  include A #mixin
  def method2()  
     puts "method2 say hi"
  end
end

class C < B #inheritance
  def method3() 
     puts "method3 say hi"
  end
end

p B.instance_methods
p C.instance_methods
