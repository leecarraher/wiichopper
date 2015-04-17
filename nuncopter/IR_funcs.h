int IRledPin =  2;  
int incomingByte = 0;
byte pulseValues[21]; //This is the IR pulse sequence, my heli uses an odd 21-bit pulse
int pulseLength = 0;
int i, id, yaw, mappedyaw;
byte throttle, trim, pitch;

void pulseIR(long microsecs) {
  cli();  // this turns off any background interrupts

  while (microsecs > 0) {
    // 38 kHz is about 13 microseconds high and 13 microseconds low
    digitalWrite(IRledPin, HIGH);  // this takes about 3 microseconds to happen
    delayMicroseconds(10);         // hang out for 10 microseconds
    digitalWrite(IRledPin, LOW);   // this also takes about 3 microseconds
    delayMicroseconds(10);         // hang out for 10 microseconds

    // so 26 microseconds altogether
    microsecs -= 26;

  }

  sei();  // this turns them back on
}

void Zero()
{  
  pulseIR(1000);
  delayMicroseconds(1000);
  pulseLength += 2000;
}

void One()
{
  pulseIR(3000);
  delayMicroseconds(1000); 
  pulseLength += 4000;
}

void sendPulseValue(int pulseValue)
{
  if (pulseValue == 1)
    One();
  else
    Zero(); 
}

void SendCode() {

//  while (true)
//  {
//    pulsetime = millis();
    
    pulseIR(5500); //Header
    delayMicroseconds(1000);
    pulseLength=6500;

    sendPulseValue(pulseValues[0]);
    sendPulseValue(pulseValues[1]);
    sendPulseValue(pulseValues[2]);
    sendPulseValue(pulseValues[3]);
    sendPulseValue(pulseValues[4]);
    sendPulseValue(pulseValues[5]);
    sendPulseValue(pulseValues[6]);
    sendPulseValue(pulseValues[7]);
    sendPulseValue(pulseValues[8]);
    sendPulseValue(pulseValues[9]);
    sendPulseValue(pulseValues[10]);
    sendPulseValue(pulseValues[11]);
    sendPulseValue(pulseValues[12]);
    sendPulseValue(pulseValues[13]);
    sendPulseValue(pulseValues[14]);
    sendPulseValue(pulseValues[15]);
    sendPulseValue(pulseValues[16]);
    sendPulseValue(pulseValues[17]);
    sendPulseValue(pulseValues[18]);
    sendPulseValue(pulseValues[19]);
    sendPulseValue(pulseValues[20]);
    
    delayMicroseconds(100);
  }

void SendLowValues() 
{
  pulseValues[0] = 0;
  pulseValues[1] = 0;
  pulseValues[2] = 0;
  pulseValues[3] = 0;
  pulseValues[4] = 0;
  pulseValues[5] = 0;
  pulseValues[6] = 0;
  pulseValues[7] = 1;
  pulseValues[8] = 0;
  pulseValues[9] = 0;
  pulseValues[10] = 0;
  pulseValues[11] = 0;
  pulseValues[12] = 0;
  pulseValues[13] = 0;
  pulseValues[14] = 1;
  pulseValues[15] = 1;
  pulseValues[16] = 1;
  pulseValues[17] = 0;
  pulseValues[18] = 1;
  pulseValues[19] = 0;
  pulseValues[20] = 0;
  SendCode();
  SendCode();
  SendCode();
}

void SendCommand(byte throttle, int yaw, byte pitch, byte trim) 
{
  
  
  throttle = map(throttle, 0, 255, 0, 31);
  yaw = map(yaw, 0, 255, 0, 31);
  mappedyaw = yaw;
  trim = map(trim, 0, 255, 0, 31);
  
///////////////////////////Pitch//////////////////////////
 // Only forward/reverse: Forward = 2, Reverse = 1, None = 0. Cheap helis like mine don't have analog pitch :'(
  if (pitch == 2)
  {
    pulseValues[18]=1;
    pulseValues[19]=1;
    pulseValues[20]=0;
  }
  else if (pitch == 1)
  {
    pulseValues[18]=0;
    pulseValues[19]=0;
    pulseValues[20]=1;
  }
  else 
  {
    pulseValues[18]=1;
    pulseValues[19]=0;
    pulseValues[20]=0;
  }

///////////////////////////Throttle//////////////////////// 
  i = 4;
  id = 2;
  while (i>=0)
  {
    if (throttle-(2^i)>=0) {
      pulseValues[id] = 1;
      throttle = throttle-(2^i);
      id++;
    }
    else {
      pulseValues[id] = 0;
      id++;
    }
    i--;
  }
///////////////////////////Yaw/////////////////////////// 
  i = 9;
  id = 7;
  while (i>=0)
  {
    if (yaw-(2^i)>=0) {
      pulseValues[id] = 1;
      yaw = yaw-(2^i);
      id++;
    }
    else {
      pulseValues[id] = 0;
      id++;
    }
    i--;
  }
  
/////////////////////////Trim/////////////////////////// 
  i = 4;
  id = 13; 
  while (i>=0)
  {
    if (trim-(2^i)>=0) {
      pulseValues[id] = 1;
      trim = trim-(2^i);
      id++;
    }
    else {
      pulseValues[id] = 0;
      id++;
    }
    i--;
  }

  SendCode();

}
