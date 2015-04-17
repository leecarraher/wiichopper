    //Arduino code to control a helicotper.
    int IRledPin =  13;    
    int incoming = 0;
    //String incomingString;
    char pulseValues[33];
    int pulseLength = 0;
     
    void setup()   {                
      // initialize the IR digital pin as an output:
      pinMode(IRledPin, OUTPUT);      
      //pinMode(13, OUTPUT);  
      Serial.begin(9600);
     
      for (int i=0; i < 13; i++)
        pulseValues[i] = 0;
     
     
    }
     
    void loop()                    
    {
      SendCode();
    }
     
     
// This procedure sends a 38KHz pulse to the IRledPin 
// for a certain # of microseconds. We'll use this whenever we need to send codes
void pulseIR(long microsecs) {
  // we'll count down from the number of microseconds we are told to wait
 
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
      pulseIR(400);
      delayMicroseconds(300);
      pulseLength += 700;
      //Serial.write('0');
    }
     
    void One()
    {
      pulseIR(850);
      delayMicroseconds(300);
      pulseLength += 1150;
      //Serial.write('1');
    }
     
    void sendPulseValue(int pulseValue)
    {
      if (pulseValue == 1)
        One();
      else
        Zero();
    }
     
    void checkPulseChanges()
    {
    /*
      if (Serial.available() > 0)
      {
        incoming = Serial.read();
        //Serial.write(incoming);
        int i = 7;
        for(;i>-1;i--){
            pulseValues[i]=incoming&1;
            incoming = incoming>>1;
        }
        incoming = Serial.read();//Serial.write(incoming);
        i = 7;
        for(;i>-1;i--){
            pulseValues[i+8]=incoming&1;
            incoming = incoming>>1;
        }
        incoming = Serial.read();//Serial.write(incoming);
        i= 7;
        for(;i>-1;i--){
            pulseValues[i+16]=incoming&1;
            incoming = incoming>>1;
        }
        incoming = Serial.read();//Serial.write(incoming);
        i = 7;
        for(;i>-1;i--){
            pulseValues[i+24]=incoming&1;
            incoming = incoming>>1;
        }
        
     
        }*/
        /*
               possible configurations is
               channel bit 1, 7bits*(yaw,throttle,pitch), channel bit 2 = 30 bits
         Ycr     yaw     tr         pi   ch
         
oncha:0 0000000 0100000 0000000  0000000 1
fullt:0 0011101 1000001 1111111  0000000 1
fTuP :0 0011110 1000001 0111000  1111000 1
fTdP :0 0011100 0100001 1111111  0111000 1
fTrY :0 0011100 0101110 1010101  0000000 1
fTlY :0 0011111 0011111 0001101  0000000 1
*may have messed channel
lYawC:0 1111111 1100001 1111111  0000000 1

//0 = 400uS   , 280
//1 = 850uS   , 680
//offTime =300us  , 320
//         send ever 120 ms
//         yaw,pitch,throttle,yawcorrect, 1 stop bit
        */
        pulseValues[0]=0;
        pulseValues[1]=0;
        pulseValues[2]=0;
        pulseValues[3]=1;  //yaw correction
        pulseValues[4]=1;
        pulseValues[5]=1;
        pulseValues[6]=0;
        pulseValues[7]=1;
        
        pulseValues[8]=1;
        pulseValues[9]=0;
        pulseValues[10]=0;
        pulseValues[11]=0;  //yaw
        pulseValues[12]=0;  
        pulseValues[13]=0;
        pulseValues[14]=1;
        pulseValues[15]=1;
        
        pulseValues[16]=1;
        pulseValues[17]=1;
        pulseValues[18]=1;
        pulseValues[19]=1;  //throttle
        pulseValues[20]=1;
        pulseValues[21]=1;
        pulseValues[22]=0;
        pulseValues[23]=0;
        
        pulseValues[24]=0;
        pulseValues[25]=0;  //pitch
        pulseValues[26]=0;
        pulseValues[27]=0;
        pulseValues[28]=0;
        pulseValues[29]=1;
        
          

        
    }
    void SendCode() {
     
      while (true)
      {
        checkPulseChanges();
     
        pulseIR(4000);
        delayMicroseconds(2000);
        pulseLength=6000;
        int i =0;
        for(;i<30;i++)
            sendPulseValue(pulseValues[i]);
        //Serial.write("\n");
     
        //Footer
        pulseIR(360);
        delayMicroseconds( (28600 - pulseLength) );
       }
    }
