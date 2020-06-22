# piper_test
## sapui5_test
Chrome headless + Node + karma + UI5 Karma addons. 
You can run Ui5 karma tests. The only thing that is required: provide karma config file. 

chrome headless + Karma + Node + possibility to extend to other testing tools.
You can now use the ever-awesome Jessie Frazelle seccomp profile for Chrome.
```
wget https://raw.githubusercontent.com/jfrazelle/dotfiles/master/etc/docker/seccomp/chrome.json -O ~/chrome.json
```
To run (without seccomp):
```
docker run -d -p 9222:9222 --cap-add=SYS_ADMIN
docker run -it -d -p 9222:9222 -p 9876:9876 --rm --name=karma --cap-add=SYS_ADMIN -v /install/GiT/employees:/usr/home/chrome karma:latest
```
To run a better way (with seccomp):
docker run -d -p 9222:9222 --security-opt seccomp=$HOME/chrome.json

Using In DevTools
Open Chrome and browse to http://localhost:9222/.
