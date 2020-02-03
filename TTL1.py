#!/usr/bin/python
import sys
import usb.core
import usb.util
import time
import RPi.GPIO as GPIO

# decimal vendor and product values
#dev = usb.core.find(idVendor=0x046D, idProduct=0xC24E)
# or, uncomment the next line to search instead by the hexidecimal equivalent
#dev = usb.core.find(idVendor=0x45e, idProduct=0x77d)
dev = usb.core.find(idVendor=0x046d, idProduct=0xc332) #Logitech G502 Proteus Spectrum mouse
# first endpoint
interface = 0
endpoint = dev[0][(0,0)][0]
# if the OS kernel already claimed the device, which is most likely true
# thanks to http://stackoverflow.com/questions/8218683/pyusb-cannot-set-configuration
if dev.is_kernel_driver_active(interface) is True:
  # tell the kernel to detach
  dev.detach_kernel_driver(interface)
  # claim the device
  usb.util.claim_interface(dev, interface)
##collected = 0
##attempts = 100+



GPIO.setmode(GPIO.BCM) #sets processor GPIO numbering sys (GPIO No.)
GPIO.setup(21, GPIO.IN) #sets pin GPIO 21 as input
#GPIO.input(21) #digitalRead(21); 0 for LOW, 1 for HIGH
pinVal = GPIO.input(21)

while pinVal == 0:
  pinVal = GPIO.input(21)

startTime = time.time()
  
while pinVal == 1 :
    try:
        data = dev.read(endpoint.bEndpointAddress,endpoint.wMaxPacketSize)
        timestamp = time.time() - startTime
        print timestamp, "," , data
        pinVal = GPIO.input(21)
    except usb.core.USBError as e:
        data = None
        if e.args == ('Operation timed out',):
            continue


##while collected < attempts :
##    try:
##        data = dev.read(endpoint.bEndpointAddress,endpoint.wMaxPacketSize)
##        collected += 1
##        timestamp = time.time() - startTime
##        print timestamp, "," , data
##    except usb.core.USBError as e:
##        data = None
##        if e.args == ('Operation timed out',):
##            continue
# release the device
usb.util.release_interface(dev, interface)
# reattach the device to the OS kernel
dev.attach_kernel_driver(interface)


GPIO.cleanup()