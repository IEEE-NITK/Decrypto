# Contains Decoder code
require "highline/import"
require "socket"
require 'thread'

class Client
  def initialize( server )
    @server = server

    @prompt = "*************************************************\n"
    @prompt += "Welcome to Decrypto. Choose one of the options: *\n"
    @prompt += "1. Scoreboard                                   *\n"
    @prompt += "2. Check cipher listing                         *\n"
    @prompt += "3. Solve a cipher: (CipherNumber:Decrypted Text)*\n"
    @prompt += "*************************************************\n\n"
    @prompt += "> "
    
    send
  end

  # Take answer as input and send to server for validation
  def solve
    str = $stdin.gets.chomp
    return "solve:"+str
  end

  # User choice
  def choose_option(option)
    case option
    when 1 then return 'scoreboard'
    when 2 then return 'listing'
    when 3 then return solve
    end
  end

  def send
    puts "Decoder Login(TeamName:Password)"
    msg = $stdin.gets.chomp
    @server.puts(msg)    
    msg = @server.gets("\0").chomp("\0")

    if msg.include? "Invalid"
      puts "#{msg}"
      return
    end

    loop {
      print @prompt
      option = gets.chomp
      msg = choose_option(option.to_i)
      @server.puts( msg )
      msg = @server.gets("\0").chomp("\0")
      puts "#{msg}"        
    }
  end
end

server = TCPSocket.open( "localhost", 3000 )
Client.new( server )
