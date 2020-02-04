# opticalBallWheelSensor
Tracking virtual reality wheels and running balls using optical sensors

The scripts above are written to run on a Raspberry Pi (tested versions: 2B, 3B, 3B+, 4B),
and record all outputs of a desired computer mouse sensor which enables precise logging 
of movement speed and direction

This is achieved by hooking into a USB interface associated with a specified USB HID 
(human interface device, in this case, a computer mouse) and capturing all its output
instead of letting the kernel.

The scripts can be used with any mouse, provided that the idVendor and idProduct
arguments are set correctly. Consult [this](http://the-sz.com/products/usbid/) website if you are not sure where to find these values
for your sensor.


There are 3 variations of the script:  
* Time1.py will record for a specified number of seconds  
* TTL_Time1.py will record for a specified number of seconds from the moment of detecting a HIGH value on GPIO pin 21  
* TTL1.py will record from the moment of detecting a HIGH value on GPIO pin 21 and until the value changes to LOW  

Execute all scripts using terminal by navigating to a containing directory and executing the following (enter the duration of recording 
as a number of second and pressing enter if prompted):
```
sudo python Time1.py
```

All scripts are set to print timestamped output, which will be output directly to the terminal in the above
use-case. This enables easy over-network recording in a headless setup using SSH if desired. 
For local recording, the code can easily be adapted to write directly to a file or the output can be captured and
recorded in terminal like this:
```
sudo python Time1.py >> recording1.txt
```

## Output

Note that output:
```
0.0199191570282 , array('B', [0, 0, 226, 255, 17, 0, 0, 0])
0.0678420066833 , array('B', [0, 0, 255, 255, 0, 0, 0, 0])
0.147843122482 , array('B', [0, 0, 0, 0, 1, 0, 0, 0])
0.16383600235 , array('B', [0, 0, 255, 255, 0, 0, 0, 0])
0.179836988449 , array('B', [0, 0, 0, 0, 1, 0, 0, 0])
```
is completely unprocessed by default for performance reasons and not
very human-readable. 


## Output processing

### Output cleaning

### Output decoding

Using `ballSensor_analysis_cleaned.R` cleaned output can be converted into running speed values.
The script decodes and bins the data to a desired frequency to ease synchronisation with other recordings 
(output frequency is set by editing the value of binsPerSecond variable). It then calculates 
an "absolute" vector of movement per a datapoint by finding a hypotenuse between the 2 axes of movement 
the mouse sensor records from. Effectively that is distance moved in the period of time defined by 
acquisition frequency, which equals speed. 