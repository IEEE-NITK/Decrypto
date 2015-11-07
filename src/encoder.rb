# Contains Encoder code
require "socket"
require 'thread'
require "word_salad"

class Client
    def initialize
        # initializes a server to host Encoder service at port 3001
        @encodeserver = TCPServer.new( 3001 ) 

        @prompt = "*************************************************\n"
        @prompt += "Welcome to Decrypto. Choose one of the options: *\n"
        @prompt += "1. Scoreboard                                   *\n"
        @prompt += "2. Generate a random string!                    *\n"
        @prompt += "# Warning: Generating a new string gives -5     *\n"
        @prompt += "*************************************************\n\n"
        @prompt += "> "

        send
    end

    # Used to generate a random string of 10(subject to change) characters and format the plaintext, ciphertext and comment in a way so that the server understands the structure of the string.
    def rand_string(client)
        str = ""

        # Generates a random english word of length 4-6 alphabets
        while str.length < 4 or str.length > 6
            str = 1.word
        end

        # Asking for cipher from EaaS
        client.puts "\n************************************************\n"
        client.puts "Your random string is - #{str}"
        client.puts "Enter your ciphertext -"
        cipher = client.gets.chomp

        # Taking comment input
        client.puts "Enter a comment -"
        comment = client.gets.chomp

        # Generation of the string
        return_string = "plain->"+str+",cipher->"+cipher+",comment->"+comment

        return return_string
    end

    # User choice
    def choose_option(option, client)
        case option 
        when 1 then return 'scoreboard'
        when 2 then return rand_string(client)
        end
    end

    def send
        loop {
            Thread.start(@encodeserver.accept) do |client|
                server = TCPSocket.open("localhost", 3000)

                client.puts "Encoder Login(TeamName:Password)"
                msg = client.gets.chomp
                server.puts(msg)
                msg = server.gets("\0").chomp("\0")

                if msg.include? "Invalid"
                    client.puts "#{msg}"
                    return
                end

                loop {
                    client.print @prompt
                    option = client.gets.chomp
                    msg = choose_option(option.to_i, client)
                    server.puts( msg )
                    msg = server.gets("\0").chomp("\0")
                    client.puts "#{msg}"         
                }
            end
        }.join
    end
end

# Create a new client
Client.new
