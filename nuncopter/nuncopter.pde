/*
This is an Arduino sketch used to control a cheap 3-channel infrared helicopter bought on DealExtreme.com,
with a Wii Nunchuk. 
 - The "IR_funcs.h" file contains code from this blog :
   http://www.avergottini.com/2011/05/arduino-helicopter-infrared-controller.html
 - The "nunchuk_funcs.h" is from Tod E. Kurt (todbot.com)
 - Everything else is CopyLeft-Licenced by me, Jonathan Rico (a1rstudios.com)

Wiring :
 - IR leds connected to digital pin 2 (via an external transistor, of course)
 - 10K potentiometer connected to analog pin 0 (used to set the trim on-the-fly)
 - nunchuk red wire (+3.3v) connected to Arduino 5V pin
 - nunchuk white wire (GND) connected to Arduino GND pin
 - nunchuk yellow wire (SCL) connected to Arduino pin A5 (SCL)
 - nunchuk green wire (SDA) connected to Arduino pin A4 (SDA)
 
I tried my best to decode the IR (infrared) pulse with an improvised logic analyser (arduino mega):
 - signal modulated at 38khz, 'ON' is 38khz pwm output activated, 'OFF' is pwm output disactivated
 - It's a 21-bit long pulse (Kinda weird, I know)
 - Header : 5.500 ms ON, 1ms OFF
 - 1 : 3ms ON, 1ms OFF
 - 0 : 1ms ON, 1ms OFF
 - Bits 0 and 1 are set to 0 (I think they're part of the header)
 - Bits 2 to 6 are the throttle: 00000 to 11111(0 to 31 in decimal)
 - Bits 7 to 16 are the yaw component (I think...)
 - Bits 13 to 17 are the trim (Offsets the yaw component, I think): 00000 to 11111 (0 to 31)
 - Bits 18 to 21 are the pitch : 110=forward, 100=no pitch, 001=backwards (Yup, my heli doesn't have an analog pitch

As you saw by the "I think" statements, I think that I screwed up decoding the yaw and the trim,
so HELP IS APPRECIATED on my instructables.com member page (just post a comment): http://instructables.com/member/a1r
BTW, you can also email me at john@a1rstudios.com . THANKS!
And, this heli control code can easely be modified for use on another helicopter (I'm lookin' at you, SYMA S107)
I'll be really happy to know that it has been used in a cool project! 

PS : I am working on a smartphone-controlled heli, so stay tuned to my instructables page and website (a1rstudios.com) !

You can buy the heli here (about 21€):
http://www.dealextreme.com/p/rechargeable-3-5-ch-r-c-helicopter-with-gyroscope-flashlight-ir-remote-6-x-aa-65640

Funtion usage :
SendCommand(throttle, yaw, pitch, trim);
 - throttle 0-255
 - yaw 0-255
 - pitch : 1=backwards, 2=forward, 0=none
 - trim 0-255
 
Voila, that's it! And as always: HAVE FUN !
*/
  
#include <Wire.h>
#include "nunchuck_funcs.h"
#include "IR_funcs.h"
#include "heli_funcs.h"
boolean safe, deadman = 0;

void setup()
{
  // initialize the IR digital pin as an output:
  pinMode(IRledPin, OUTPUT);      
  pinMode(13, OUTPUT);   
  nunchuck_init(); //Initialise the nunchuk
  Serial.begin(115200); //You can disable this if you don't want debug output
  delay(200); //Wait for the nunchuk to be operational
  altitude = 1; //Set the heli's altitude (rotor speed) to 1
}

void loop()                     
{
  delay(20);
  nunchuck_get_data(); //Tell the nunchuk to spit out new values
  deadman = nunchuck_cbutton(); //Deadman's switch (Nunchuk C button)
  
  if(deadman)
  {
    GetNunchukValues(); //Get the nunchuk's joystick/accelerometer values and adapt them(constrain+map)
    SetPitch(); //Set the pitch (Forward/Reverse/Still)
    SetAbsoluteAltitude(); //Set the blades' speed ( For Relative Altitude, use SetRelativeAltitude(); funtion )
    SendCommand(altitude, joyx, pitch, pot); //Send the nicely-prepared values to the heli via a 21-bit ~50ms long IR pulse
    DebugOutput();  //Also send the values (including timing) to the serial output
    safe = 0;
  }
  else
  {
    while (!safe)
    {
    SendLowValues();
    safe = 1; //The safe variable is only used for preserving the transmitter battery life :
    }         //this variable is here so when the heli has been stopped with the SendlowValues(),
  }           //then we can stop wasting battery by stopping the looping IR pulse transmission.
}
