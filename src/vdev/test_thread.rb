#
#
def test1
  t1 = Thread.start {input_loop}

  loop do
    puts "message B"
    sleep(2)
  end
end

def input_loop
  loop do
    print "=> "
    buff = gets
    puts "input is #{buff}"
  end
end

begin
  test1
  
# rescue => exception
  
end