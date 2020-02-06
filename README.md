# opticalBallWheelSensor
Tracking virtual reality wheels and running balls (as commonly used in rodent neuroscientific experiments) using computer mouse sensors


## Background

The scripts above are written to run on a Raspberry Pi (tested versions: 2B, 3B, 3B+, 4B),
and record all outputs of a desired computer mouse sensor which enables precise logging 
of movement speed and direction

This is achieved by hooking into a USB interface associated with a specified USB HID 
(human interface device, in this case, a computer mouse) and capturing all its output
instead of using it to move a mouse cursor.

The scripts can be used with any mouse, provided that the idVendor and idProduct
arguments are set correctly. Consult [this](http://the-sz.com/products/usbid/) website if you are not sure where to find these values
for your sensor. I recommed partially dissasembling the mouse to isolate the sensor and the PCBs before use
so no part of mouse body touches the tracked item of choice.


## Use

There are 3 variations of the script:  
* Time1.py will record for a specified number of seconds  
* TTL_Time1.py will record for a specified number of seconds from the moment of detecting a HIGH value on GPIO pin 21  
* TTL1.py will record from the moment of detecting a HIGH value on GPIO pin 21 and until the value changes to LOW  

Execute all scripts using terminal by navigating to a containing directory and executing one of the following lines 
(enter the duration of recording as a number of seconds and press enter if prompted):
```
sudo python Time1.py
sudo python TTL_Time1.py
sudo python TTL1.py
```

All scripts are set to print timestamped output, which will be output directly to the terminal in the above
use-case. This enables easy over-network recording in a headless setup using SSH if desired. 
For local recording, the code can be easily adapted to write directly to a file or the output can be captured and
recorded in terminal like this (the following will record all sensor data to recording1.txt file):
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

Using `ballSensor_analysis_wPy.R` output can be converted into binned running speed values.
The script cleans, decodes and bins the data to a desired frequency to ease synchronisation with other recordings 
(output frequency is set by editing the value of binsPerSecond variable). It then calculates 
an "absolute" vector of movement per a timepoint by finding a hypotenuse between the 2 axes of movement 
the mouse sensor records from (left to right and forward to backward). 

To use, set R working directory to a folder containing any number of .txt files recorded by any of the
sensor recording scripts and run the .R file. Files containing timestamped and binned running speed data 
will be located in a subfolder `processed/` with original names to which `__binned_nHz` has been appended (n standing for
selected binning frequency). Furthermore, a `cl/` subfolder will be created with cleaned, but not in any way processed files.
Ensure that line 150 in R script `py_run_file(...` contains a correct path to `cleanBallData_r1.py` file.




## Extras

By adding `usbhid.mousepoll = 0` to `/boot/cmdline.txt` file on the RPi and restarting, the mouse sensor polling rate
will stop being limited by the OS to 62.5Hz and will be set to a rate requested by the device. This can be up to 1000Hz in 
some high-end gaming mice and can usually be further adjusted in the software (e.g. Logitech G HUB).