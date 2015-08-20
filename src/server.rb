# Contains Server Code

require "socket"
class Server
  
  # Used to initialize server variables 
  def initialize( port, ip )
  	# Used to open the TCP socket on the given port
    @server = TCPServer.open( ip, port )
    
    # Contains client connection details
    @connections = Hash.new
    @clients = Hash.new
    @connections[:server] = @server
    @connections[:clients] = @clients

    # Game data
    @scoreboard = Hash.new
    @public_ciphers = Hash.new
    
    run
  end

  # All messages coming from the Encoder/Decoder are structured in a specific format. Function parses the incoming string and runs appropriate functions.
  def parse_message(message, username)
  	if message.include? 'scoreboard'
  		# Used to show the game scoreboard
  		return "Scoreboard:"
  	elsif message.include? 'plain->' and message.include? 'cipher->' and message.include? 'comment->'
  		data = []
  		
  		######

  		# The following code segment is used to extract plaintext, ciphertext and comment from the Encoder
  		message.split(',').each do |str|
  			data.push str.split('->')[1]
  		end

      new_cipher = Hash.new

      new_cipher['plain'] = data[0]
      new_cipher['cipher'] = data[1]
      new_cipher['comment'] = data[2]

  		@public_ciphers[username]['list'].push new_cipher

      return "Done."
  	end
  end

  # Used to fork a thread for every new connection.
  def run
    loop {
      Thread.start(@server.accept) do | client |
        nick_name = client.gets.chomp.to_sym
        @connections[:clients].each do |other_name, other_client|
          if nick_name == other_name || client == other_client
            client.puts "This username already exists."
            Thread.kill self
          end
        end
        puts "#{nick_name} #{client}"
        @connections[:clients][nick_name] = client
        
        #############
        # Game data #
        #############

        @scoreboard[nick_name] = 0
        @public_ciphers[nick_name] = Hash.new
        @public_ciphers[nick_name]['list'] = []
        
        listen_user_messages( nick_name, client )
      end
    }.join
  end

  # Listens for user messages.
  def listen_user_messages( username, client )
    loop {
      msg = client.gets.chomp
      str = parse_message(msg, username)
      client.puts str
    }
  end
end

Server.new( 3000, "localhost" )