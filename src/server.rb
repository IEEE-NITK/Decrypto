# Contains Server Code
require "highline/import"
require "socket"

class Server
  
  # Used to initialize server variables 
  def initialize( port, ip )
  	# Used to open the TCP socket on the given port
    @server = TCPServer.open( ip, port )
    
    # Contains details of users connected to the server.
    @users = Hash.new

    # Game data
    @score = Hash.new
    @public_ciphers = []
    
    run
  end

  # Used to parse messages incoming to the server. Takes appropriate action.
  def parse_message(message, username)
  	if message.include? 'scoreboard'
  		  
      s_b = ""
      s_b += "************************************************\n"

      temp_score = @score
      temp_score.sort_by {|key, value| value}.reverse

      # Needs to be beautified.
      temp_score.each do |team, current_score|
        s_b += "#{team}: #{current_score}\n"
      end

      s_b += "************************************************\n\n\0"
      return s_b
  	
    elsif message.include? 'plain->' and message.include? 'cipher->' and message.include? 'comment->'

      data = []

  		# The following code segment is used to extract plaintext, ciphertext and comment
  		message.split(',').each do |str|
  			data.push str.split('->')[1]
  		end

      # new_cipher is used to store cipher-related data.

      new_cipher = Hash.new

      new_cipher[:plain]   = data[0]
      new_cipher[:cipher]  = data[1]
      new_cipher[:comment] = data[2]

      team_name = @users[username][:team]
      new_cipher[:team] = team_name

      # Adds the new cipher to the existing list
  		@public_ciphers.push new_cipher

      # Reduce team score for publishing a cipher by 5
      @score[team_name] -= 5
      
      pub = ""
      pub += "*************************************************\n"
      pub += "Published.\n"
      pub += "*************************************************\n\0"

      return pub

  	elsif message.include? 'listing'
      
      # Needs beautification
      c_l = ""
      c_l += "*************************************************\n"
      # Variable for indexing into the cipher array
      count=1

      @public_ciphers.each do |c_hash|
        c_l += "#{count}. Ciphetext: #{c_hash[:cipher]}, Comment: #{c_hash[:comment]}, Team: #{c_hash[:team]}\n"
        count+=1
      end

      c_l += "*************************************************\n\n\0"

      # Returns list of all ciphers with team name and comment
      return c_l
    
    elsif message.include? 'solve'

      # Split message to get all fields
      solve, number, text = message.split(':')
      
      # Cipher the user wants to solve
      cipher = @public_ciphers[(number.to_i)-1]
      team_name = @users[username][:team]

      if cipher[:plain] == text and cipher[:team] == team_name
        @score[team_name] += 10
        return "Solved your own cipher!\0"
      
      elsif cipher[:plain] == text and cipher[:team] != team_name
        @score[team_name] += 2
        @score[cipher[:team]] -= 1
        return "Solved other teams' cipher.\0"
      
      else
        return "Wrong submission\0"
      end

    end
  end

  # Used to fork a thread for every new connection.
  def run
    loop {
      Thread.start(@server.accept) do | client |
        type, t_name, u_name = client.gets.chomp.split(':')

        if t_name == nil or u_name == nil or type == nil
          client.puts "Invalid: Login.\0"
          Thread.kill self
        end

        @users.each do |username, details|
          if username == u_name
            client.puts "Invalid: This username already exists.\0"
            Thread.kill self
          elsif details[:team] == t_name and details[:type] == type
            client.puts "Invalid: Team login.\0"
            Thread.kill self
          end
        end

        # Initialize User
        @users[u_name] = Hash.new
        @users[u_name][:team] = t_name
        @users[u_name][:type] = type

        # Initialize score
        @score[t_name] = 0
        client.puts "\n\0"
        
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