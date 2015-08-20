# Contains Server Code

require "socket"
class Server
  
  # Used to initialize server variables 
  def initialize( port, ip )
  	# Used to open the TCP socket on the given port
    @server = TCPServer.open( ip, port )
    
    # Contains client connection details
    @users = Hash.new

    # Game data
    @score = Hash.new
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

      new_cipher[:plain]   = data[0]
      new_cipher[:cipher]  = data[1]
      new_cipher[:comment] = data[2]

      puts new_cipher.inspect

      t_name = @users[username][:team]
      puts t_name
  		@public_ciphers[t_name].push new_cipher
      return "Published."

  	elsif message.include? 'listing'
      puts @public_ciphers.inspect
      c_l = ''

      @public_ciphers.each do |team, array|
        c_l += "Cipher listing for team #{team}: \n"
        for c_hash in array
          puts hash.inspect
          c_l += "Ciphetext: #{c_hash[:cipher]}, Comment: #{c_hash[:comment]}\n"
        end
        c_l += "**************"
      end

      return c_l
    end
  end

  # Used to fork a thread for every new connection.
  def run
    loop {
      Thread.start(@server.accept) do | client |
        type, t_name, u_name = client.gets.chomp.split(':')

        @users.each do |username, details|
          if username == u_name
            client.puts "This username already exists."
            Thread.kill self
          end
        end

        u_name = u_name.to_sym

        @users[u_name] = Hash.new
        @users[u_name][:type] = type
        @users[u_name][:team] = t_name

        @score[t_name] = 0
        @public_ciphers[t_name] = []
        
        listen_user_messages( u_name, client )
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