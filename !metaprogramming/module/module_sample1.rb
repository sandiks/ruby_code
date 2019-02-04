
p "---------------------sample 1------------------"

module Foo
  
  def self.included(base)
    base.class_eval do
      def self.method_injected_by_foo
        p "self.method_injected_by_foo self: #{self}"
      end
    end
  end

end

module Bar
  def self.included(base)

    base.method_injected_by_foo
  end
end

class Host
  include Foo # We need to include this dependency for Bar
  include Bar # Bar is the module that Host really needs
end

p "---------------------sample 2------------------"

module SomeModule
  def self.included(klass)
    puts "SomeModule was included in #{klass.inspect}"
  end
end

Class.new { include SomeModule }  # prints "SomeModule was included in #<Class:0x007fe17884f768>"
Object.new.extend SomeModule      # nothing printed