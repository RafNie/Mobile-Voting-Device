 # Mobile Voting Device

Project of mobile device designed for performing voting in small groups of people (max 8). Voters connect to this device through WiFi network using smartphones, laptops. The device is based on ESP8266 modules and nodeMCU firmware.

Project is developed within cooperation between Technical University of Lodz and Ericsson Poland as "Mały Oxford" program.


## Getting Started

Project is developed under nodeMCU firmware in LUA scripting language
[nodeMCU](https://github.com/nodemcu/nodemcu-firmware)

NodeMCU firmware was modified to allow connect up to 8 users to the WiFi AP, to use with our project. The modified firmware will be delivered in the future. Without this modification only 4 users can connect to the access point at one time.
Setting up and performing of voting is realized using web browser.


### Instaling

Scripts and html files can be uploaded to the developing board by using ESPlorer IDE
[ESPlorer](https://github.com/4refr0nt/ESPlorer)


### Hardware configuration

Under developing was used NodeMCU v3 developing board with 4MB flash. Only connecting power to the board is necessary to work.

Device can also signal the state and the result using RGB LED.
To use this feature it is necessary to connect anode of the diodes (with suitable resistors) to the I/O pins of module. Pins are worked in PWM mode.

Pin configiration:
red - 5,
green - 6,
blue - 7.


## Authors

* **Cezary Bocianiak** - *Developing*
* **Grzegorz Boreczek** - *Developing*
* **Hanna Alhawash** - *Developing*
* **Rafal Niedzwiedzinski** - *Idea and support for developers*


## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details

