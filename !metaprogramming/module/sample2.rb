module M

  module ClassMethods
    def class_method
      p 'some class method'
    end
  end

  def self.m_ify(klass)
    klass.extend ClassMethods
    klass.send :include, self
  end

  def instance_method
    p 'some instance method'
  end
end

c = Class.new
M.m_ify c
c.class_method # => "some class method"
p c.instance_methods# => "some instance method"