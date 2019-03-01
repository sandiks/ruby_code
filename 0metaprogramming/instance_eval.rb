string = "String"
string2 = "String"

string2.instance_eval do
  def new_method
    self.reverse
  end
end

p string2.new_method

obj = "11111112222"
other = obj.dup


p obj == other      #=> true
p obj.equal? other  #=> false
obj.equal? obj    #=> true