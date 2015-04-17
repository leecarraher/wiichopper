#import pid
import wiiuse
import sys
import time
import os
from Tkinter import *


'''
Byte 1: Yaw
Byte 2: Pitch
Byte 3: Throttle
Byte 4: Yaw correction from Remote.

They all use the last 7 bits of the byte.
Throttle goes from 0 to 126, while pitch and yaw start centered in 63.
'''
class CRTL:
    yaw= 63
    pitch = 63
    throttle = 0
    yawCorrect = 63


nmotes = 1

def handle_event(wmp):
    wm = wmp[0]
    #print '--- EVENT [wiimote id %i] ---' % wm.unid
    currentX,currentY = 0,0
    if wiiuse.using_ir(wm):
        for i in range(4):
            if wm.ir.dot[i].visible:
                currentX = wm.ir.x
                currentY = wm.ir.y
                #print currentX,currentY
        #print 'IR z distance: %f' % wm.ir.z
    return currentX,currentY

def handle_disconnect(wmp):
    print 'disconnect'


if os.name != 'nt': print 'Press 1&2'
wiimotes = wiiuse.init(nmotes)

found = wiiuse.find(wiimotes, nmotes, 5)
if not found:
    print 'not found'
    sys.exit(1)

connected = wiiuse.connect(wiimotes, nmotes)
if connected:
    print 'Connected to %i wiimotes (of %i found).' % (connected, found)
else:
    print 'failed to connect to any wiimote.'
    sys.exit(1)

for i in range(nmotes):
    wiiuse.set_leds(wiimotes[i], wiiuse.LED[i])
    wiiuse.status(wiimotes[0])
    wiiuse.set_ir(wiimotes[0], 1)
    wiiuse.set_ir_vres(wiimotes[i], 500, 500)



import serial
ser = serial.Serial()
ser.port = "/dev/ttyUSB0" # may be called something different
ser.baudrate = 9600 # may be different
ser.open()
print "initialized Serial Controller"

        
def signal(w):

    if ser.isOpen():
        cmd = chr(int(w.yaw)) + chr(int(w.pitch)) +chr(int(w.throttle)) + chr(int(w.yawCorrect))
        ser.write(cmd)

    


#initialize the pid

targetPositionX = 250#depends on wii's camera, basically the middle
targetPositionY = 250#
class PID:
     derState = 1.0
     intState = 0.0
     intMax=10.0
     intMin=0.0
     intGain=0.10
     propGain=0.10
     derGain=.5




def update(pid, error, position):
    propTerm = pid.propGain * error# calculate the proportional term 

    # calculate the integral state with appropriate limiting 
    pid.intState =pid.intState  +error
    if pid.intState > pid.intMax: 
        pid.intState = pid.intMax 
    elif pid.intState < pid.intMin:
        pid.intState = pid.intMin 

    inteTerm = pid.intGain * pid.intState
    dervTerm = pid.derGain * (position - pid.derState) 
    pid.derState = position
    return propTerm + inteTerm #- dervTerm #; this blows up my test example


try:
    command = CRTL()
    print "initialized PID(pitch,throttle)"
    pidX = PID()
    print pidX.propGain,pidX.intGain,pidX.derGain    
    pidY = PID()
    print pidY.propGain,pidY.intGain,pidY.derGain
    
    
    root = Tk()
    canvas = Canvas(width=500,height=500,bg='white')
    canvas.pack(expand=YES,fill=BOTH)
    

    canvas.create_oval(targetPositionX,targetPositionY,targetPositionX+10,targetPositionY+10)
    prevOval =canvas.create_oval(0,0,0,0)
    time1 = ''
    clock = Label(root, font=('times', 20, 'bold'), bg='green')
    clock.pack(fill=BOTH, expand=1)
     
    def tick():

        global prevOval
        r = wiiuse.poll(wiimotes, 1)
        while not r :
            r = wiiuse.poll(wiimotes, 1)
        
        #actual PID stuff
        positionx,positiony = handle_event(wiimotes[0])
        newcmdX = update(pidX,targetPositionX-positionx,positionx)

        if abs(newcmdX)<10.0:
            print "Equilibrium X"
        else:
            print "x:"+str(newcmdX)+":"+str(command.pitch)
            command.pitch = newcmdX + command.pitch
            if command.pitch>127:command.pitch =127
            if command.pitch <1:command.pitch =1
            
            signal(command)
        
        newcmdY = update(pidY,targetPositionY-positiony,positiony)
        if abs(newcmdY)<10.0:
            print "Equilibrium Y"
        else:
            print "y:"+str(newcmdY)+":"+str(command.throttle)
            command.throttle = command.throttle+newcmdY
            if command.throttle>127:command.throttle=127
            if command.throttle<1:command.throttle=1
            signal(command)

        time.sleep(.01)
        
        #drawing the interface thing (debug)
        canvas.delete(prevOval)
        AA = (positionx,500-positiony)
        #clock.config(text=str(positionx)+','+str(positiony))
        prevOval = canvas.create_oval(AA[0],AA[1],AA[0]+2,AA[1]+2)
        clock.after(10, tick)
    tick()
    root.mainloop( )
 

         
except KeyboardInterrupt:
    for i in range(nmotes):
        #use as warnings, ie power is too low to hover/amount of power needed for equilibrium, a passive fuel meter
        #wiiuse.set_leds(wiimotes[i], 0)
        #wiiuse.rumble(wiimotes[i], 0)
        wiiuse.disconnect(wiimotes[i])


    
#positionz
