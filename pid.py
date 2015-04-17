class PID:
     derState = 0.0
     intState = 0.0
     intMax=2.0
     intMin=0.0
     intGain=1.0
     propGain=1.0
     derGain=1.0

def Update(pid, error, position):
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
  print propTerm,inteTerm,dervTerm
  return propTerm + inteTerm #- dervTerm #; this blows up my test example

pre=0
import pylab
def evalStateEqn(x,num,den):
    global pre
    n = len(num)
    num = [(x**((n-i)-1))*num[i] for i in range(n)]
    n = len(den)
    num = [(x**((n-i)-1))*den[i] for i in range(n)]
    y = sum(num)/sum(den)+500+pre
    pre = y
    return y

        
    
pylab.plot( pylab.arange(0.0,10.0,.1),[evalStateEqn(x,[1],[5000,50]) for x in pylab.arange(0.0,10.0,.1)])
import random 
pylab.show()

dat = []
pid = PID()

drive = 1.0
for i in range(10):
    #if i%10:newPt = newPt+random.gauss(0.0,.50) #read wiimote
    y = 0#nOrderSystem(drive,2)
    dat.append(y) #just for graphing
    error = target-y
    print error
    drive = Update(pid,error,y)

    
pylab.plot(dat)
pylab.show()

    
