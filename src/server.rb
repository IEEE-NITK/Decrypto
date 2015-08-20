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
    @public_ciphers = []
    
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

      t_name = @users[username][:team]
      new_cipher[:team] = t_name


  		@public_ciphers.push new_cipher
      @score[t_name] -= 5
      return "Published."

  	elsif message.include? 'listing'
      c_l = "**************\n\n"
      count=1

      @public_ciphers.each do |c_hash|
        c_l += "#{count}. Ciphetext: #{c_hash[:cipher]}, Comment: #{c_hash[:comment]}, Team: #{c_hash[:team]}\n"
        count+=1
      end

      return c_l
    elsif message.include? 'solve'
      puts message.inspect
      solve, number, text = message.split(':')
      cipher = @public_ciphers[(number.to_i)-1]
      t_name = @users[username][:team]

      if cipher[:plain] == text and cipher[:team] == t_name
        @score[t_name] += 10
        return "Solved your own cipher!"
      elsif cipher[:plain] == text and cipher[:team] != t_name
        @score[t_name] += 2
        @score[cipher[:team]] -= 1
        return "Solved other teams' cipher."
      else
        return "Wrong submission"
      end
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