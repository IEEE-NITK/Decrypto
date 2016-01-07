# Contains Decoder code
require "socket"
require 'thread'

class Client
    def initialize
        # Initialising a server to host Decoder service at port 3002
        @decodeserver = TCPServer.new( 3002 )

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
    def solve(client)
        str = client.gets.chomp.split(':')

        return_obj = {}
        return_obj['type'] = "solve"
        return_obj['index'] = str[0]
        return_obj['text'] = str[1]
        
        return return_obj
    end

    def scoreboard
        return_obj = {}
        return_obj['type'] = "scoreboard"

        return return_obj
    end

    def listing
        return_obj = {}
        return_obj['type'] = "listing"

        return return_obj
    end

    # User choice
    def choose_option(option, client)
        case option
        when 1 then return scoreboard
        when 2 then return listing
        when 3 then return solve(client)
        end
    end

    def send
        loop{
            Thread.start(@decodeserver.accept) do |client|
                server = TCPSocket.open("localhost", 3000)

                client.puts "Decoder Login(TeamName:Password)"
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
