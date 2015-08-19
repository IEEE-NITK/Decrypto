# Encoder specific code goes here

def generate_string(size = 8)
  size = 8 if size <= 0
  (0...size).map { ('a'..'z').to_a[rand(26)] }.join
end