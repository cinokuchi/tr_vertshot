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
        return backingArray[(nextIndex - offset - 1 + MAXSIZE) % MAXSIZE]
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
}

function OnPostSpawn(){
    AddThinkToEnt(self, "OnTick")
}

/*
    Where O is the eye position as a vector,
    D is the eye direction as a vector,
    and tickOffset is the amount of ticks backwards to check the position of the target
*/
function checkHit(Ox, Oy, Oz, Dx, Dy, Dz, tickOffset){
    local lagRecord = circularBuffer.get(tickOffset)
    if(lagRecord == null)
        return
    local O = Vector(Ox, Oy, Oz)
    local D = Vector(Dx, Dy, Dz)
    local N = lagRecord.angle.Forward()
    local C = lagRecord.origin
    printl("N: " + N + "; C: " + C + "; D: " + D + "; O: " + O)
    //local t = -dot(O - C, N)/dot(D, N)
}