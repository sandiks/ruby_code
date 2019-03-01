module MyMod
  def meth
    "from module"
  end
end
class ParentClass
  def meth
    "from parent"
  end
end
class ChildClass < ParentClass
  include MyMod #prepend MyMod
  def meth
    "from child"
  end
end

x = ChildClass.new

p x.meth
p x.class.ancestors
p x.instance_of? ChildClass
