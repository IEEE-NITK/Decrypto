# Contains Decoder code
# Yet to be implemented
require "socket"
class Client
  def initialize( server )
    @flag = 0
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
        if @flag==0
          msg = @server.gets.chomp
          puts "#{msg}"
      }
    end
  end

  def choose_option(option)
    case option
    when 1 then return 'scoreboard'
    when 2 then return 'listing'
    end
  end

  def send
    puts "Enter the username:"
    msg = $stdin.gets.chomp
    @server.puts(msg)    
    @request = Thread.new do
      loop {
        puts "*************************\nWelcome to Decrypto. Choose one of the options:"
        puts "1. Scoreboard"
        puts "2. Check cipher listing"
        option = $stdin.gets.chomp
        msg = choose_option(option.to_i)
        @server.puts( msg )
      }
    end
  end
end

server = TCPSocket.open( "localhost", 3000 )
Client.new( server )