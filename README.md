# Lane Detection

A final year BEng electronics project that aims to detect lanes on a road from a live video feed. Using an FPGA, the lanes are detected by applying the sobel operator combined with searching for pixels brighter than a variable threshold.

## Demonstration

https://user-images.githubusercontent.com/62083547/172941356-2ffd6f28-229f-4e7b-8cfc-a31fc2a52e07.mp4

This demonstration shows a recording of the screen which displays the processed video. The red markers are produced by the FPGA to indicate the position of the lane.

## Schematic

[<img src="https://user-images.githubusercontent.com/62083547/172941392-5587d8ab-dda5-4b5b-903f-97942c6ce8a8.svg" alt="Schematic"/>](https://github.com/TomBazley/Lane-Detection/blob/master/PCB/PCB.kicad_sch)

A circuit board was designed which includes an iCE40 FPGA, a VGA port for video input, a VGA-to-digital conversion chip, a STM32 microcontroller to configure the FPGA and VGA converter, and a display to view the processed images. The circuit board also features a power supply, overvoltage protection, and reverse polarity protection.

# PCB

[<img src="https://user-images.githubusercontent.com/62083547/173107673-11a8f625-2f99-467c-9f79-5bfe7cf4deaf.png" alt="PCB1"/>](https://github.com/TomBazley/Lane-Detection/blob/master/PCB/)
[<img src="https://user-images.githubusercontent.com/62083547/173107695-81846cb7-44e6-4f60-af4a-f01f738e316f.png" alt="PCB2"/>](https://github.com/TomBazley/Lane-Detection/blob/master/PCB/)