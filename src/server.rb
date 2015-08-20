# Contains Server Code

# Generating a random word - -5
RAND_WORD_GEN = -5

# Solving your own cipher - +10
OWN_CIPHER_SOLVED = 10

# Solving other teams' cipher - +2
OTHER_CIPHER_SOLVED = 2

# If your cipher gets solved - -1
OWN_CIPHER_SOLVED_BY_OTHER = -1

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
  def parse_message(message, username, client)
    if message.include? 'scoreboard'
      # Used to show the game scoreboard
      score_str = get_score
      return score_str
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
      
      update_score(t_name, RAND_WORD_GEN)

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
    elsif message.include? 'guessing'
      cipher_t_name, cipher, plaintext = message.split("->")[1].split(":")
      own_t_name = message.split("->")[2]
      @public_ciphers[cipher_t_name].each do |p_c|
        if p_c[:cipher] == cipher
          if p_c[:plaintext] == plaintext
            if cipher_t_name == own_t_name
              update_score(own_t_name, OWN_CIPHER_SOLVED)
            else
              update_score(own_t_name, OTHER_CIPHER_SOLVED)
              update_score(cipher_t_name, OWN_CIPHER_SOLVED_BY_OTHER)
            end
            return "Succesfully solved cipher."
          else
            return "Please try again."
          end
        end
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
        @public_ciphers[t_name] = []
        
        listen_user_messages( u_name, client )
      end
    }.join
  end

  # Listens for user messages.
  def listen_user_messages( username, client )
    loop {
      msg = client.gets.chomp
      str = parse_message(msg, username, client)
      client.puts str
    }
  end

  def get_score
    score_str = ""
    @score.each do |t_name, val|
      score_str += "Score of team #{t_name}: #{val}\n"
    end
    score_str
  end

  def update_score(t_name, status)
    @score[t_name] += status
  end
end

Server.new( 3000, "localhost" )