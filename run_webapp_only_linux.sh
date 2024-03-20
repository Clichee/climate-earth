# Run server on new terminal, open web app afterwards
port=8080
terminal node dev-server.js $port
xdg-open http://localhost:$port

# Important information for developers. Using the same port shortly after closing the server on the same port
# will cause the browser to use cached data (i think?) and changed functionality will not be shown.
