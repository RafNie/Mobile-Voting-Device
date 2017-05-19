 # Mobile Voting Device

Project of mobile device designed for performing voting in small groups of people ( less than 8). Voters connect to this device through WiFi network using smartphones, laptops. The device is based on ESP8266 modules and nodeMCU firmware.

Project is developed within cooperation between Technical University of Lodz and Ericsson Poland as "Mały Oxford" Program.


## Getting Started

Project is developed under nodeMCU firmware in LUA scripting language
[nodeMCU](https://github.com/nodemcu/nodemcu-firmware)

NodeMCU firmware was modified to allow connect up to 8 users to the WiFi AP, to use with our project. The modified firmware will be delivered in the future. Without this modification only 4 users can connect to the access point at one time.

Under developing was used NodeMCU v3 developing board with 4MB flash.

### Instaling

Scripts and html files can be uploaded to the developing module by using ESPlorer IDE
[ESPlorer](https://github.com/4refr0nt/ESPlorer)

### Hardware configuration


Device can also signal a state and result using RGB LED.
To use this feature it is necessary to connect anode of the diodes (with suitable resistors) to the I / O pins of module. Pins are worked in PWM mode, so smooth changing of colors is possible.
Pin configiration:
red	7,
green	6,
blue	5,
It will be delivered in near future!


## Authors

* **Cezary Bocianiak** - *Developing*
* **Grzegorz Boreczek** - *Developing*
* **Hanna Alhawash** - *Developing*
* **Rafal Niedzwiedzinski** - *Idea and support for developers*


## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details

