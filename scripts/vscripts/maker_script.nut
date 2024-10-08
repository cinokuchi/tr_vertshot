function rad2Deg(rad)
{
	return rad / PI * 180
}
function deg2Rad(deg)
{
	return deg / 180.0 * PI
}

//Returns -1 if the operand is less than one, and 1 otherwise
function getSign(operand)
{
	return (operand < 0 ? -1 : 1)
}

//Returns the greater of the two operands
function max(arg1, arg2){
	if(arg1 > arg2)
		return arg1
	else
		return arg2
}

//Returns the lesser of the two operands
function min(arg1, arg2){
	if(arg1 < arg2)
		return arg1
	else
		return arg2
}

//Converts U to Horz
function getHorzFromU(uRatio){
	return asin(uRatio)
}

function getUFromHorz(horz){
	return sin(horz)
}

/*
	Takes degrees and returns radians
	This formula calculates the VFOV, then
		divides by 2 to get offset from screen middle to screen top/bottom
*/
function getVertOffsetFromSourceFOV(sourceFOV){
	return atan(3 * tan(deg2Rad(sourceFOV/2)) / 4)
}

/*
	Takes degrees and returns radians
	This formula calculates the HFOV,
		divides by 2 to get offset from screen middle to screen left/right,
		and divides by 2 again just to force a more narrow spawn area.
*/
function getHorzOffsetFromSourceFOV(sourceFOV){
	return atan(4 * tan(deg2Rad(sourceFOV/2)) / 3) / 2
}

HALF_OF_PI <- deg2Rad(90)
/*
	Takes degrees and returns hammer units.
	Given an FOV, returns a target distance to keep
		apparent size roughly the same.
	32 and HALF_OF_PI are arbitrary - I decided
		640 hammer units of distance when source FOV is 90 deg are good numbers.
		The rest comes from the visual angle formula.
*/
function getRhoFromSourceFOV(sourceFOV){
	return 32 / tan(atan(1.0/20.0) * deg2Rad(sourceFOV)/HALF_OF_PI)
}
//---------------------------------------------------------------------------------------------------------------------------
m_hSpawner <- Entities.CreateByClassname("env_entity_maker")
m_hSpawner.__KeyValueFromString( "EntityTemplate", "targetTemplate")

//Approximate headposition standing on edge of platform.
TARGET_ORIGIN <- Vector(536, 0, 1090)

nextUOrigin <- 0.0
nextVertOrigin <- 0.0
rho <- 0
uOffset <- 0.0
vertOffset <- 0.0
vertMin <- 0.0
vertMax <- 0.0
uMin <- 0.0
uMax <- 0.0
UP <- 0
DOWN <- 1
walkDirection <- UP
walkIncrement <- 0.0

SPAWN_NEARBY <- 0
SPAWN_WALKING <- 1
spawnMode <- SPAWN_WALKING
EPSILON <- 0.001 //for rounding errors

//------------------------------------------------------------------------------------------------------------------------

VERT_MIN <- deg2Rad(-50)
VERT_MAX <- deg2Rad(85)
function setFov(sourceFOV){
	rho <- getRhoFromSourceFOV(sourceFOV)
	uOffset <- getUFromHorz(getHorzOffsetFromSourceFOV(sourceFOV))
	vertOffset <- getVertOffsetFromSourceFOV(sourceFOV)
	//roughly 3 increments per vertOffset,
	//then ceil such that there are a whole number of walk increments per VERT_MAX - VERT_MIN
	walkIncrement = (VERT_MAX - VERT_MIN) / (3*ceil((VERT_MAX - VERT_MIN) / vertOffset))
	//printl("vertOffset: " + rad2Deg(vertOffset))
	//printl("walkIncrement: " + rad2Deg(walkIncrement))
	uMin <- -uOffset
	uMax <- uOffset
}

function setSpawnWalking(){
	spawnMode = SPAWN_WALKING
}
function setSpawnNearby(){
	spawnMode = SPAWN_NEARBY
}

function walkSpawns(){
	if(walkDirection == UP && nextVertOrigin >= VERT_MAX - EPSILON){
		nextVertOrigin = VERT_MAX
		walkDirection = DOWN
	}
	if(walkDirection == DOWN && nextVertOrigin <= VERT_MIN + EPSILON){
		nextVertOrigin = VERT_MIN
		walkDirection = UP
	}
	
	if(walkDirection == UP){
		nextVertOrigin = nextVertOrigin + walkIncrement
	}
	if(walkDirection == DOWN){
		nextVertOrigin = nextVertOrigin - walkIncrement
	}
}

function resetTargets(){
	nextUOrigin = 0.0
	nextVertOrigin = 0.0
	walkDirection = UP
    removeAllTargets()
}

//Provides a random u ratio in the legal bounds, in radians.
function getRandomU(){
	return RandomFloat(max(uMin, nextUOrigin - uOffset), min(uMax, nextUOrigin + uOffset))
}

//Provides a random vert angle in the legal bounds, in radians.
function getRandomVert(){
	return RandomFloat(max(VERT_MIN, nextVertOrigin - vertOffset), min(VERT_MAX, nextVertOrigin + vertOffset))
}

//returns a vector
function vertHorzToCartesian(rho, horz, vert)
{
	local rho_cosHorz = rho * cos(horz)
	return Vector(-rho_cosHorz*cos(vert), rho*sin(horz), rho_cosHorz*sin(vert))
}

lastCreatedU <- 0
lastCreatedVert <- 0
function makeTarget()
{
	lastCreatedU = getRandomU()
	lastCreatedVert = getRandomVert()
	local position = vertHorzToCartesian(rho, getHorzFromU(lastCreatedU), lastCreatedVert)
	//acos only returns positive
	local phi = getSign(position.x) * rad2Deg(acos(position.z/rho))
	local theta = position.x == 0 ? getSign(position.y) * 90 : rad2Deg(atan(position.y/position.x))
	local direction = Vector(
			phi,
			theta,
			0)
	//printl("maker.makeTarget() - nextVertOrigin: " + nextVertOrigin + "; nextUOrigin: " + nextUOrigin)
	//printl("maker.makeTarget() - lastCreatedU: " + lastCreatedU + "; lastCreatedVert: " + lastCreatedVert)
	m_hSpawner.SpawnEntityAtLocation(position + TARGET_ORIGIN, direction)
	
	if(spawnMode == SPAWN_WALKING)
		walkSpawns()
}

/*
//Make target at a specific horz and vert
//for debug purposes
//Takes horz and vert in degrees
function makeTargetAtLocation(horz, vert)
{
	local position = vertHorzToCartesian(rho, horz, vert)
	//acos only returns positive
	local phi = getSign(position.x) * rad2Deg(acos(position.z/rho))
	local theta = position.x == 0 ? getSign(position.y) * 90 : rad2Deg(atan(position.y/position.x))
	local direction = Vector(
			phi,
			theta,
			0)
	m_hSpawner.SpawnEntityAtLocation(position + TARGET_ORIGIN, direction)
}*/

//------------------------------------------------------------------------------------------------------------------------
//Can't pass object handles through EntFire's third argument so as a hack I'm passing it as the caller.
targetTable <-{}

/*
    Saves a target to the targetTable
*/
function addTarget(logic_script_handle)
{
    //printl("addTarget called on handle " + logic_script_handle)
    targetTable[logic_script_handle] <- {
        uRatio=lastCreatedU
        vertAngle=lastCreatedVert
    }
}

/*
    Removes a target from the target table
*/
function removeTarget(logic_script_handle)
{
    //printl("removeTarget called on handle " + logic_script_handle)
    
    if(!(logic_script_handle in targetTable)){
        //TODO: see if I can trigger the race condition again and if its here consistently then I might be gucci with just a return statement here.
        printl("There's about to be a race condition")
    }
    
    //if SPAWN_NEARBY, then the next spawn location will be based off of the just-destroyed spawn location
	if(spawnMode == SPAWN_NEARBY){
		nextUOrigin = targetTable[logic_script_handle]["uRatio"]
		nextVertOrigin = targetTable[logic_script_handle]["vertAngle"]
		//printl("nextUOrigin: " + nextUOrigin + "; nextVertOrigin: " + nextVertOrigin)
	}
    
    //Clean out table entry
    delete targetTable[logic_script_handle]["uRatio"]
    delete targetTable[logic_script_handle]["vertAngle"]
    
    //delete from table
    delete targetTable[logic_script_handle]
    
    /*printl("remaining targets:")
    foreach(logic_script_handle, targetRecord in targetTable){
        printl("\t" + logic_script_handle)
    }*/
}

function removeAllTargets()
{
    foreach(logic_script_handle, targetRecord in targetTable){
        removeTarget(logic_script_handle)
    }
    //Broadcasts to all targets that they must destroy theirselves
    EntFire("target_logic_script*", "RunScriptCode", "destroyTarget()")
}

//------------------------------------------------------------------------------------------------------------------------