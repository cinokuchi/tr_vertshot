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

// Arbitrary "small number"
EPSILON <- pow(10, -6)
// Circular buffer of lag records
circularBuffer <- CircularBuffer()
// Handle to maker_script
makerHandle <- null

/*
    Where O is the eye position as a vector,
    D is the eye direction as a vector,
    and tickOffset is the amount of ticks backwards to check the position of the target
*/
function computeClosestApproach(Ox, Oy, Oz, Dx, Dy, Dz, tickOffset){
    local lagRecord = circularBuffer.get(tickOffset)
    if(lagRecord == null)
        return

    // eye direction
    local D = Vector(Dx, Dy, Dz)
    // target's plane normal vector
    local N = lagRecord.angle.Forward()
    local denom = N.Dot(D)
    // eye direction is parallel to plane
    if(fabs(denom) < EPSILON)
        return

    // eye position
    local O = Vector(Ox, Oy, Oz)
    // target position
    local C = lagRecord.origin
    local t = -N.Dot(O - C) / N.Dot(D)
    // target is behind the player
    if(t < 0)
        return
    
    // closest point of shot to target
    local P = O + D.Scale(t)
    // distance from target squared
    return (P - C).LengthSqr()
}

function OnTick(){
    circularBuffer.put(LagRecord(self.GetAbsAngles(), self.GetOrigin()))
}

function registerMaker(){
    //printl("Received maker handle " + caller)
    makerHandle = caller
}

function OnPostSpawn(){
    AddThinkToEnt(self, "OnTick")
    //printl("Requesting registration for " + self)
	DoEntFire("maker_logic_script", "RunScriptCode", "registerTarget0()", 0, null, self)
}

function die(){
    //printl("dying " + self)
    makerHandle.AcceptInput("RunScriptCode", "deregisterTarget0()", null, self)
    self.GetRootMoveParent().Destroy()
}