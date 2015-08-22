# Contains Encoder code
require "highline/import"
require "socket"
require 'thread'

class Client
  def initialize( server )
    @server = server

    @prompt = "*************************************************\n"
    @prompt += "Welcome to Decrypto. Choose one of the options: *\n"
    @prompt += "1. Scoreboard                                   *\n"
    @prompt += "2. Generate a cipher!                           *\n"
    @prompt += "*************************************************\n\n"
    @prompt += "> "

    send
  end

  # Used to generate a random string of 10(subject to change) characters and format the plaintext, ciphertext and comment in a way so that the server understands the structure of the string.
  def rand_string
    str = (0...10).map { ('a'..'z').to_a[rand(26)] }.join
    
    # Asking for cipher from EaaS
    puts "\n************************************************\n"
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
    puts "Encoder Login(TeamName:Username):"
    msg = $stdin.gets.chomp
    @server.puts("encoder:"+msg)
    msg = @server.gets("\0").chomp("\0")

    if msg.include? "Invalid"
      puts "#{msg}"
      return
    end

    loop {
      option = ask @prompt
      msg = choose_option(option.to_i)
      @server.puts( msg )
      msg = @server.gets("\0").chomp("\0")
      puts "#{msg}"         
    }
  end
end

server = TCPSocket.open( "localhost", 3000 )
Client.new( server )