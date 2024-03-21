# Run webapp on new terminal, open web app afterwards
port=8080
terminal node dev-server.js $port
xdg-open http://localhost:$port

# Change directory to backend-server and run it in a new terminal
cd backend-server
terminal sh run_server_linux.sh 

# Important information for developers. Using the same port shortly after closing the server on the same port
# will cause the browser to use cached data (i think?) and changed functionality will not be shown.
