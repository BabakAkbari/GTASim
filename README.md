# GTASim

GTASim is an open source simulator based on GTA V for drones, planes, cars, boats and various other vehicles integrated with [ArduPilot](https://github.com/ArduPilot/ardupilot), a popular full-featured and reliable open source autopilot software. 

## How to use it

### Installing FiveM client

GTASim is built on a customized dedicated FiveM server. You need to install FiveM client to connect to the server.
Follow the instructions in the link to [install FiveM Client](https://docs.fivem.net/docs/client-manual/installing-fivem/).
* Make sure you have installed and updated GTA V.
* Download [FiveM](https://fivem.net/) off the website.
* Run FiveM.exe. If you run the installer in an empty folder, FiveM will install there. Otherwise, it will install in `%localappdata%\FiveM`.

### Setting up a server

Follow the instructions in the link to [set up your FXServer](https://docs.fivem.net/docs/server-manual/setting-up-a-server/). 
You can install FXServer on both [Windows](https://docs.fivem.net/docs/server-manual/setting-up-a-server/#windows) and [Linux](https://docs.fivem.net/docs/server-manual/setting-up-a-server/#linux). Throughout this instruction, we assume that we are using Windows to run the server.

After you set up the server, you need to clone GTASim in your resources under the path `FXServer\server-data\resources\[local]` and run the server.

```

cd FXServer\server-data\resources\[local]
git clone https://github.com/BabakAkbari/GTASim.git
cd FXServer\server-data
FXServer\server\FXServer.exe +exec server.cfg
```

### Connecting to the Server

Run FiveM.exe, click on the `localhost` button in the developer mode to connect to the server or simply press `F8`. This will open up your client console then type `connect loalhost:30120` to connect to your server. After the game is loaded, go back to your server console and execute `start GTASim` to run GTASim scripts. For more information, visit [Scripting manual](https://docs.fivem.net/docs/scripting-manual/) 

### Using GTASim with ArduPilot

Follow the instructions in the link to [set up SITL](https://ardupilot.org/dev/docs/SITL-setup-landingpage.html).
<del> **Currently suport for copter has been developed in GTASim**. </del>
The JSON SITL backend allows GTASim to easily interface with ArduPilot using a standard JSON interface. 
Execute the following commands to launch SITL using JSON backend. This will open up MAVProxy's command line.
```
cd ardupilot
sim_vehicle.py -v ArduCopter --console --map -f json:127.0.0.1
```
where `127.0.0.1` is replaced with the IP GTASim is running at.
Go back to the game press `t` and type `/drone` in the text field. This will spawn a drone next to the PED on the ground in First-Person View. In order to switch between cameras press `t` and type `/cam` in the text field. 
Go back to MAVProxy's command line and type `arm throttle` to arm the motors and then type `rc 3 1800` to lift the drone up.
For more infomation, visit [Using SITL](https://ardupilot.org/dev/docs/using-sitl-for-ardupilot-testing.html).

### Using Lidar

Press `F8` to open the client console. Use `con_miniconChannels *` command to display console messages on screen without needing to open the client console.
Once you get into the game, press `t` and type `/rover raiden` to spawn a car. press `f` to get in the car. you must be able to see the measured distance on the bottom left corner. (A list of available vehicle models is documented in [List] (https://wiki.gtanet.work/index.php?title=Vehicle_Models))

## Contributing Code
If you want to conbtribute to the code, go through the FiveM [Documentaion](https://docs.fivem.net/docs/).
You can also find some useful information on how to get started scripting in the link [Creating your first script in Lua](https://docs.fivem.net/docs/scripting-manual/introduction/creating-your-first-script/).
Also a full list of native functions is available on [FiveM Natives](https://runtime.fivem.net/doc/natives/).