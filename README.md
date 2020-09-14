# GTASim

GTASim is an open-source simulator based on GTA V for drones, planes, cars, boats and various other vehicles integrated with [Ardupilot](https://github.com/ArduPilot/ardupilot) a full-featured and reliable open source autopilot software. 

## How to use it

### Installing FiveM client

GTASim is built on a customized dedicated FiveM server. You need to install FiveM client to connect to the server.
Follow the instructions in the link to [install FiveM Client](https://docs.fivem.net/docs/client-manual/installing-fivem/).
* Make sure you have installed and updated GTA V.
* Download [FiveM](https://fivem.net/) off the website.
* Run FiveM.exe. If you run the installer in an empty folder, FiveM will install there. Otherwise, it will install in `%localappdata%\FiveM`.

### Setting up a server

Follow the instructions in the link to [set up your FXServer](https://docs.fivem.net/docs/server-manual/setting-up-a-server/). 
You can install FXServer on both [Windows](https://docs.fivem.net/docs/server-manual/setting-up-a-server/#windows) and [Linux](https://docs.fivem.net/docs/server-manual/setting-up-a-server/#linux). Throughout this instruction we assume that we are using Windows to run the server.

After you set up the server, you need to clone GTASim in your resources under the path `FXServer\server-data\resources\[local]` and run the server.

```

cd FXServer\server-data\resources\[local]
git clone https://github.com/BabakAkbari/GTASim.git
cd FXServer\server-data
FXServer\server\FXServer.exe +exec server.cfg
```

### Connecting to the Server

Run FiveM.exe, click on the `localhost` button in the developer mode to connect to the server or simply press `F8`. This will open up your client console then type `connect loalhost:30120` to connect to your server. After the game is loaded go back to your server console and execute `start GTASim` to run GTASim scripts. For more information visit [Scripting manual](https://docs.fivem.net/docs/scripting-manual/) 

### Using GTASim with Ardupilot
