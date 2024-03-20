:: Run webapp on new terminal, open web app afterwards
set port=8080
start cmd /k node dev-server.js %port%
start http://localhost:%port%

:: Change directory to backend-server and run it in a new terminal
cd backend-server
start cmd /k run_server.bat 

:: Important information for developers. Using the same port shortly after closing the server on the same port
:: will cause the browser to use cached data (i think?) and changed functionality will not be shown.
