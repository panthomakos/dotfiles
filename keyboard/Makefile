.PHONY: deps flash

deps:
	if [ -d "Model01-Firmware" ]; then \
		cd Model01-Firmware && git clean -df && git checkout -- . && git pull && \
		cd $(HOME)/Arduino/hardware/keyboardio/avr && git submodule update; \
	else \
		curl https://downloads.arduino.cc/arduino-1.8.8-linux64.tar.xz -o arduino.tar.xz && \
		mkdir -p arduino && \
		tar -xvf arduino.tar.xz -C arduino --strip-components 1 && \
		rm arduino.tar.xz && \
		sudo curl https://raw.githubusercontent.com/keyboardio/Kaleidoscope/master/etc/99-kaleidoscope.rules -o /etc/udev/rules.d/99-kaleidoscope.rules && \
		git clone git@github.com:keyboardio/Model01-Firmware.git && \
		mkdir -p ${HOME}/Arduino/hardware && \
		git clone --recursive https://github.com/keyboardio/Kaleidoscope-Bundle-Keyboardio.git ${HOME}/Arduino/hardware/keyboardio; \
	fi

permissions:
	sudo usermod -a -G uucp $(USER) && \
	sudo usermod -a -G lock $(USER)

flash:
	cp ./Model01-Firmware.ino ./Model01-Firmware && \
	cd ./Model01-Firmware && \
	ARDUINO_PATH=../arduino make flash
