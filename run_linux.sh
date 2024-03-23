# Run webapp on new terminal, open web app afterwards
port=8080
gnome-terminal -- node dev-server.js $port
xdg-open http://localhost:$port

# Change directory to backend-server and run it in a new terminal
cd backend-server

gnome-terminal -- bash -c "python3 -m uvicorn main:app --reload; exec bash"
# This weird statement above will leave the terminal open after executing the backend server. It would close otherwise

# Important information for developers. Using the same port shortly after closing the server on the same port
# will cause the browser to use cached data (i think?) and changed functionality will not be shown.
