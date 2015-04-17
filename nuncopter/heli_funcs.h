byte accx,accy,zbut,cbut,joyx,joyy;
int altitude, pot;

void GetNunchukValues() {
  joyy = nunchuck_joyy(); //Retrieve nunchuk values
  joyx = nunchuck_joyx();
  accx = nunchuck_accelx();
  accy = nunchuck_accely();
  
  joyy = constrain(joyy, 50, 220); //Constrain 'em
  joyx = constrain(joyx, 31, 218);
  accx = constrain(accx, 80, 180);
  accy = constrain(accy, 60, 180);
  joyy = map(joyy, 50, 220, 0, 255); //Map 'em to standard bytes
  joyx = map(joyx, 31, 218, 0, 255);
  accx = map(accx, 80, 180, 0, 255);
  accy = map(accy, 70, 180, 0, 255);
  accy = map(accy, 0, 255, 255, 0);
  
  pot = analogRead(0);              // Map the trim to an external potentiometer on A0;
  pot = map(pot, 0, 1023, 0, 255);
}

void SetRelativeAltitude() {
  if (accy < 100) 
    {                                         //Set the heli's altitude,
      accy = map(accy, 0, 255, 255, 0);       //we're not using absolute
      altitude = int(altitude - (accy*0.02)); //joystick mapping, but
    }                                         //altitude incrementation
    else if (accy > 160) {
      altitude = int(altitude + (accy*0.02));
    }
    else {
      //do nothing
    }
    altitude = constrain(altitude, 0, 255);
}

void SetAbsoluteAltitude() {
  altitude = accy;
}


void SetPitch() {
    if (joyy <=80)  //Set the pitch (on my heli, there's no analog pitch, it's
    {               //forward/reverse/none)
      pitch = 1;
    }
    else if (joyy >= 160) 
    {
      pitch = 2;
    }
    else 
    {
      pitch = 0;
    }
}

void DebugOutput() {
  for (i=0; i<=20; i++) {  //Debug output: outputs IR pulse, yaw, altitude, pitch.
    Serial.print(pulseValues[i], DEC);
    }
    Serial.print("\tpitch : ");
    Serial.print(pitch, DEC);
    Serial.print("\tyaw : ");
    Serial.print(mappedyaw, DEC);
    Serial.print("\taltitude : ");
    Serial.print(altitude, DEC);
    Serial.print("\ttrim : ");
    Serial.println(pot, DEC);
}
