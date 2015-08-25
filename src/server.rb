#!/usr/bin/env ruby

# Contains Server Code, yet to add comments
require "socket"
require "json"

class Server

    # Used to initialize server variables 

    #######################
    #       Server        #
    #######################

    def initialize( port, ip )

        @server = TCPServer.new( port )

        intitialize_score
        initialize_cipher
        initialize_login

        run
    end

    ####################
    # Server run code  #
    ####################
    
    def run
        loop {
            Thread.start(@server.accept) do | client |
                t_name, password = client.gets.chomp.split(':')

                if t_name == nil or @login[t_name] != password
                    client.puts pp("Invalid: Login.")
                    Thread.kill self
                end

                initialize_team_score(t_name) if @score[t_name].nil?
                client.puts "\n\0"

                listen_user_messages( t_name, client )
            end
        }.join
    end

    def listen_user_messages( team_name, client )
        loop {
            msg = client.gets.chomp
            str = parse_message(msg, team_name)
            client.puts str
        }
    end

    ##############################################
    # Function to parse incoming client messages #
    ##############################################

    def parse_message(message, team_name)
        case 
        when is_scoreboard?(message) then scoreboard
        when is_cipher?(message)     then publish(message, team_name)
        when is_listing?(message)    then listing
        when is_attempt?(message)    then solve(message, team_name)
        else wrong_submission
        end
    end


    ###########################
    # Message parsing actions #
    ###########################

    def scoreboard
        score_string = ""
        board        = get_scoreboard
        board.each do |team, current_score|
            score_string += "#{team}: #{current_score}\n"
        end
        return pp(score_string)
    end

    def publish(message, team_name)
        new_cipher        = generate_cipher(message, team_name)
        update_score(team_name, -5)

        return pp("Published")
    end

    def listing
        cipher_string = ""
        @public_ciphers.each_with_index do |c_hash, index|
            cipher_string +=  add_hash(c_hash, index)
        end        

        return pp(cipher_string)
    end

    def solve(message, team_name)
        index, text = get_plaintext(message)
        return pp("Wrong Submission.")           if !valid_cipher?(index)

        cipher = get_cipher(index)

        return pp("Wrong submission.")           if !correct_answer?(cipher, text)
        return pp("You have already solved it!") if already_solved?(cipher, team_name)

        if solved_by_same_team?(cipher, team_name)
            update_score(team_name, 10)
            update_cipher_solves(index, team_name)
            return pp("Solved your own cipher!")
        else
            update_score(team_name, 10)
            update_score(cipher[:team_name], -5)
            return pp("Solved other teams' cipher!.")
        end
    end

    ###########################
    # Initializer Methods     #
    ###########################

    def initialize_team_score(team_name)
        @score[team_name] = 0
        write_score
    end

    def initialize_score
        @score = load_score
    end

    def initialize_cipher
        @public_cipher = []
    end

    def initialize_login
        @login = load_login
    end

    def load_score
        JSON.parse(File.read("../save_data/score.json"))
    end
    
    def load_login
        JSON.parse(File.read("../save_data/login.json"))
    end

    ###########################
    # Helper Methods          #
    ###########################

    def pp(string)
        "********************************\n" + string + "**********************************\n\0"
    end

    def write_score
        File.open("../save_data/score.json", "w") do |f|
            f.write(@score.to_json)
        end
    end

    def wrong_submission
        pp("Wrong input.")
    end 

    ###########################
    # Validator Methods       #
    ###########################

    def is_scoreboard?(message)
        message.include? "scoreboard"
    end
    
    def is_cipher?(message)
       message.include? "plain->" and message.include? "cipher->" and message.include? "comment->"
    end
    def is_listing?(message)
        message.include? "listing"
    end

    def is_solve?(message)
        message.include? "solve"
    end

    def valid_cipher?(index)
        !(index==0)
    end

    def already_solved?(cipher, team_name)
        cipher[:solved].include? team_name
    end

    def solved_by_same_team?(cipher, team_name)
        cipher[:team] == team_name
    end
    
    def correct_answer?(cipher, text)
        cipher[:plain] == text
    end

    ###########################
    # Getter Methods          #
    ###########################

    def get_cipher(index)
        @public_ciphers[index-1]
    end    

    def get_scoreboard
        @score.sort_by {|key, value| value}.reverse
    end    

    def get_plaintext(message)
        message = message.split(":")
        return message[1].to_i, message[2]
    end   

    ###########################
    # Setter Methods          #
    ###########################

    def update_score(team_name, score)
        @score[team_name] += score
        write_score
    end

    def update_cipher_solves(index, team_name)
        @public_ciphers[index-1][:solved].push team_name
    end

    def generate_cipher(message, team_name)
        cipher_data = []

        message.split(",").each do |str|
            cipher_data.push str.split("->")[1]
        end        

        cipher = Hash.new
        cipher[:plain] = cipher_data[0]
        cipher[:cipher] = cipher_data[1]
        cipher[:comment] = cipher_data[2]
        cipher[:solved] = []
        cipher[:team_name] = team_name

        return cipher
    end

    def add_hash(c_hash, index)
        string = ""
        string += "#{index}."
        string += "Cipher: #{c_hash[:cipher]}"
        string += "Comment: #{c_hash[:comment]}"
        string += "Team: #{c_hash[:team]}"
        string += "Solves : #{c_hash[:solved].length}"

        return string
    end

end

Server.new( 3000, "localhost" )
