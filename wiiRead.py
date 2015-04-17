import wiiuse

import sys
import time
import os



nmotes = 1

def handle_event(wmp):
    wm = wmp[0]
    #print '--- EVENT [wiimote id %i] ---' % wm.unid
    
    if wiiuse.using_ir(wm):
        for i in range(4):
            if wm.ir.dot[i].visible:
                currentX = wm.ir.x
                currentY = wm.ir.y
                print currentX,currentY
        #print 'IR z distance: %f' % wm.ir.z
        
   
def handle_disconnect(wmp):
    print 'disconnect'

def init():
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
        wiiuse.set_ir_vres(wiimotes[i], 1000, 1000)

    try:
        rum = 1
        while True:
            r = wiiuse.poll(wiimotes, nmotes)
            if r != 0:
                handle_event(wiimotes[0])
    except KeyboardInterrupt:
        for i in range(nmotes):
            wiiuse.set_leds(wiimotes[i], 0)
            wiiuse.rumble(wiimotes[i], 0)
            wiiuse.disconnect(wiimotes[i])

def getCurrX():
    return currentX

def getCurrY():
    return currentY

init()

print 'done'
