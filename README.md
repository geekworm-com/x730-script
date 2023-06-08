# x730-script
This is the safe shutdown script for x730;

NOTE:

We test this shell script base official Raspbian '2018-11-13-raspbian-stretch.img' version;
We test this shell script base official Raspbian '2019-09-26 Raspbian Buster' version also;

How to use?

* step 1:
> wget https://raw.githubusercontent.com/geekworm-com/x730-script/master/x730.sh

> sudo chmod +x x730.sh

> sudo bash x730.sh

* step 2:

> printf "%s\\n" "alias x730off='sudo x730shutdown.sh'" >> ~/.bashrc

* step 3:
> sudo reboot

* how to safe shut down, run the following command:
> x730off
