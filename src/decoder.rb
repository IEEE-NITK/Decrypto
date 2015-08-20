# Contains Decoder code

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
    @t_name = nil
  end

  def listen
    @response = Thread.new do
      loop {
          msg = @server.gets.chomp
          puts "#{msg}"
      }
    end
  end

  def choose_option(option, t_name)
    case option
    when 1
      return 'scoreboard'
    when 2
      return 'listing'
    when 3
      puts "Enter all (TeamName:Cipher:Plaintext):"
      str = $stdin.gets.chomp
      return "guessing->#{str}->#{t_name}"
    end
  end

  def send
    puts "Decoder Login(TeamName:Username):"
    msg = $stdin.gets.chomp
    @t_name = msg.split(":")[0]
    @server.puts('decoder:'+msg)    
    @request = Thread.new do
      loop {
        puts "*************************\nWelcome to Decrypto. Choose one of the options:"
        puts "1. Scoreboard"
        puts "2. Check cipher listing"
        puts "3. Enter plaintext for cipher"
        option = $stdin.gets.chomp
        msg = choose_option(option.to_i, @t_name)
        @server.puts( msg )
      }
    end
  end
end

server = TCPSocket.open( "localhost", 3000 )
Client.new( server )