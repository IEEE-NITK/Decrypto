#!/usr/bin/env ruby

# Contains Server Code
require "socket"
require "json"

class Server
  
  # Used to initialize server variables 
  def initialize( port, ip )
  	# Used to open the TCP socket on the given port
    @server = TCPServer.new( port )

    # Game data
    @score = Hash.new
    @score = JSON.parse(File.read("../save_data/score.json"))
    @public_ciphers = []

    @login = load_login_info
    
    run
  end

  # Writes score to file, just in case the server goes down duting game time.
  def write_score
    File.open("../save_data/score.json", "w") do |f|
        f.write(@score.to_json)
    end
  end

  def load_login_info
    return JSON.parse(File.read("../save_data/login.json"))
  end

  # Used to parse messages incoming to the server. Takes appropriate action.
  def parse_message(message, team_name)
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

      new_cipher[:team] = team_name

      # Adds the new cipher to the existing list
  		@public_ciphers.push new_cipher

      # Reduce team score for publishing a cipher by 5
      @score[team_name] -= 5
      write_score
      
      pub = ""
      pub += "*************************************************\n"
      pub += "Published.\n"
      pub += "*************************************************\n\0"

      return pub

  	elsif message.include? 'listing'
      
      # Needs beautification
      c_l = ""
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
      message = message.split(":")
      number, text = message[1], message[2]
      
      # Cipher the user wants to solve
      cipher = @public_ciphers[(number.to_i)-1]

      if cipher[:plain] == text and cipher[:team] == team_name
        @score[team_name] += 10
        write_score
        return "Solved your own cipher!\0"
      
      elsif cipher[:plain] == text and cipher[:team] != team_name
        @score[team_name] += 2
        @score[cipher[:team]] -= 1
        return "Solved other teams' cipher!\0"
      
      else
        return "Wrong submission.\0"
      end
    else
      return "Wrong input.\0"
    end
  end

  # Used to fork a thread for every new connection.
  def run
    loop {
      Thread.start(@server.accept) do | client |
        t_name, password = client.gets.chomp.split(':')

        if t_name == nil
          client.puts "Invalid: Login.\0"
          Thread.kill self
        elsif @login[t_name] != password
          client.puts "Invalid Login.\0"
          Thread.kill self
        end

        # Initialize score
        if @score[t_name] == nil
          @score[t_name] = 0
          write_score
        end

        client.puts "\n\0"
        
        listen_user_messages( t_name, client )
      end
    }.join
  end

  # Listens for user messages.
  def listen_user_messages( team_name, client )
    loop {
      msg = client.gets.chomp
      str = parse_message(msg, team_name)
      client.puts str
    }
  end
end

Server.new( 3000, "localhost" )
