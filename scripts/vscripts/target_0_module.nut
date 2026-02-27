class CircularBuffer{
    static MAXSIZE = 100; 

    backingArray = null
    nextIndex = 0

    constructor(){
        backingArray = []
        backingArray.resize(MAXSIZE)
    }
    
    function get(offset){
        if(offset >= MAXSIZE){
            return null
        }
        return backingArray[(nextIndex - 1 - offset + MAXSIZE) % MAXSIZE]
    }

    function put(val){
        backingArray[nextIndex] = val
        nextIndex = (nextIndex + 1) % MAXSIZE
    }
}

class LagRecord{
    angle = null
    origin = null
    constructor(angle, origin){
        this.angle = angle
        this.origin = origin
    }
}

circularBuffer <- CircularBuffer()

function OnTick(){
    circularBuffer.put(LagRecord(self.GetAbsAngles(), self.GetOrigin()))
    return -1
}

function OnPostSpawn(){
    AddThinkToEnt(self, "OnTick")
}

// Arbitrary "small number"
EPSILON <- pow(10, -6)

RADIUS_SQRD <- null

/*
    Where O is the eye position as a vector,
    D is the eye direction as a vector,
    and tickOffset is the amount of ticks backwards to check the position of the target
*/
function computeClosestApproach(Ox, Oy, Oz, Dx, Dy, Dz, tickFraction, lowTick){
    local lowLagRecord = circularBuffer.get(lowTick)
    local highLagRecord = circularBuffer.get(lowTick + 1)
    if(lowLagRecord == null || highLagRecord == null)
        return
    
    // Do interpolation
    // target's plane normal vector
    local lowN = lowLagRecord.angle.Forward()
    local highN = highLagRecord.angle.Forward()
    local N = (lowN - highN) * tickFraction + highN
    // target positioon
    local lowC = lowLagRecord.origin
    local highC = highLagRecord.origin
    local C = (lowC - highC) * tickFraction + highC


    // eye direction
    local D = Vector(Dx, Dy, Dz)
    local denom = N.Dot(D)
    // eye direction is parallel to plane
    if(fabs(denom) < EPSILON)
        return

    // eye position
    local O = Vector(Ox, Oy, Oz)
    local t = -N.Dot(O - C) / N.Dot(D)
    // target is behind the player
    if(t < 0)
        return
    
    // closest point of shot to target
    local P = O + D.Scale(t)
    // distance from target squared
    return (P - C).LengthSqr()
}