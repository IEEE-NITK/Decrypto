kill -9 `ps aux | grep server.rb | grep -v grep | awk '{print $2}'`&
kill -9 `ps aux | grep encoder.rb | grep -v grep | awk '{print $2}'`&
kill -9 `ps aux | grep decoder.rb | grep -v grep | awk '{print $2}'`