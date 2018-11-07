module TestMod
  def m_func
    puts "m_func"
    c_func if method_defined?(:c_func)
  end
end

class TestClass
  include TestMod

  def c_func
    puts "c_func"
    # m_func
  end 
end 

begin
  c = TestClass.new
  #c.c_func
  c.m_func
end 