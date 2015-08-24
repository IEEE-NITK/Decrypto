### Decrypto
Final event as a part of IEEE Computer Society First year fest 2015-16.

### Details of the event
The event consists of a team divided into two parties - Encoder and 2*Decoders.

`Encoder`: 
Will be given an option to generate a random string of characters. They will be encrypted using one of the many encryption schemes provided to them. Ciphertext will be made public along with a comment which is supposed to be understood only to decoders from the same team.

`Decoders`:
Will be given access to all the ciphers. Based on the comments provided by the encoders they will have to solve the particular problem.

### Scoring system:

* Generating a random word  `-5`<br>
* Solving your own cipher    `+10`<br>
* Solving other teams' cipher `+2`<br>
* If your cipher gets solved  `-1`<br>

### Setting up
Start `server.rb`, `encoder.rb` and `decoder.rb`.<br>
For encoder: `nc localhost 3001`<br>
For decoder: `nc localhost 3002`<br>

(You can change the IP/ports in the corresponding files)

Requirements: Ruby

### Contributing
1. Create a branch as -> `handle-dev` for example -> `chinmay_dd-dev`.
2. Create a PR to master. Make sure to include a simple changelog.
3. IMPORTANT - Master should contain only stable code.
4. Commit messages should be in present tense preferably.
5. Make sure to write decent comments for complex methods.

This project is under MIT license.
