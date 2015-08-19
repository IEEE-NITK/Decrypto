# Contains Encoder code
# Yet to be implemented

require "socket"
class Client
  def initialize( server )
    @server = server
    @request = nil
    @response = nil
    listen
    send
    @request.join
    @response.join
  end

  def listen
    @response = Thread.new do
      loop {
        msg = @server.gets.chomp
        puts "#{msg}"
      }
    end
  end

  # Used to generate a random string of 10(subject to change) characters and format the plaintext, ciphertext and comment in a way so that the server understands the structure of the string.
  def rand_string
    str = (0...10).map { ('a'..'z').to_a[rand(26)] }.join
    
    # Asking for cipher from EaaS
    puts "Your random string is - #{str}"
    puts "Enter the ciphertext using the EaaS provided -"
    cipher = $stdin.gets.chomp
    
    # Taking comment input
    puts "Enter a comment -"
    comment = $stdin.gets.chomp
    
    # Generation of the string
    return_string = "plain->"+str+",cipher->"+cipher+",comment->"+comment
    
    return return_string
  end

  # User choice
  def choose_option(option)
    case option 
    when 1 then return 'scoreboard'
    when 2 then return rand_string
    end
  end

  # Needs to be polished.
  def send
    puts "Enter the username:"
    @request = Thread.new do
      loop {
        msg = $stdin.gets.chomp
        puts "Welcome to Decrypto. Choose one of the options:"
        puts "1. Scoreboard"
        puts "2. Generate a random string and publicize."
        option = $stdin.gets.chomp
        msg = choose_option(option.to_i)
        puts msg.inspect
        @server.puts( msg )
      }
    end
  end
end

server = TCPSocket.open( "localhost", 3000 )
Client.new( server )