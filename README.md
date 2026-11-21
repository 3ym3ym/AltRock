## Direct Conversion Receiver with signal demodulation in RP2040 ##

<img width="1331" height="717" alt="DCRX_26_10_sch" src="https://github.com/user-attachments/assets/a168704f-faf2-4d43-813e-8aba11104d0c" />


This is a low-cost small receiver which plugs into a PC and looks like a soundcard and a CAT interface on the USB port.
The receiver hardware contains: 
- LPF or BPF input filter
- KISS topology I/Q mixer
- Si5351A I/Q LO on a plugin board (Adafruit clone from Aliexpress)
- Discrete transistor 50dB audio preamps, plus additional 15dB gain stages to match the typical signal levels to the ADC input range
- PCM1808 ADC on a plugin board (fake from Aliexpress)
- RP2040-Zero plugin board (same source)

The total BOM can be <$20. 

The input filter is not switched. It can be implemented as a single band BPF, or an LPF to receive a 3x frequency range. For example, a 30MHz LPF allows to receive 10..30MHz. Lower frequencies are received, but there is sensitivity to 3rd harmonic of the LO: when tuned to 7MHz, it will receive both 7 and 21MHz signals.

Schematic and PCB design was done in KiCad. Provided Gerber files can be uploaded to JLCPCB or another PCB manufacturing service.
The PCB is shaped to fit into an Altoids tin. There is a 3D design for an insert to mount the board inside the box. You need to cut holes for the USB connector and your choice of the antenna connector. I punched a 1/4in hole for SMA and soldered it to the inside of the box.

The heart of the receiver is the firmware that runs on RP2040.
- I2S interface to PCM1808 in master mode, generating necessary clocks
- Demodulates SSB or AM from I/Q
- Audio bandpass filter and AGC
- USB soundcard endpoint, 48kHz/16-bit mono. No drivers required on Windows or Linux.
- Si5351A frequency control
- Software USB serial port endpoint for CAT control, TS-480 command subset
- Another serial port to control parameters which don't have CAT equivalents

A typical use is FT8 monitoring with WSJT-X software. Plug in the receiver, configure WSJT-X to use TS-480 CAT interface and the new soundcard called "Pico", and start monitoring. Band hopping will work within the limits of the installed input filter.

There is also a version of the firmware which doesn't have the demodulator. It presents I/Q raw data to he host PC in stereo 96kHz/16-bit format, for use with SDR software like HDSDR or Quisk.


