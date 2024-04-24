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

//------------------------------------------------------------------------------------------------------------------------
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

//------------------------------------------------------------------------------------------------------------------------

VERT_MIN <- deg2Rad(-50)
VERT_MAX <- deg2Rad(90)
function setFov(sourceFOV){
	rho <- getRhoFromSourceFOV(sourceFOV)
	uOffset <- getUFromHorz(getHorzOffsetFromSourceFOV(sourceFOV))
	vertOffset <- getVertOffsetFromSourceFOV(sourceFOV)
	uMin <- -uOffset
	uMax <- uOffset
}

function setLastTargetLocation(uRatio, vertAngle){
	nextUOrigin = uRatio
	nextVertOrigin = vertAngle
	printl("nextUOrigin: " + nextUOrigin + "; nextVertOrigin: " + nextVertOrigin)
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
	printl("maker.makeTarget() - lastCreatedU: " + lastCreatedU + "; lastCreatedVert: " + lastCreatedVert)
	m_hSpawner.SpawnEntityAtLocation(position + TARGET_ORIGIN, direction)
}

/*
//Make target at a specific horz and vert
//for debug purposes
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

function PreSpawnInstance( entityClass, entityName )
{
	return null
}

function PostSpawn( entities )
{
	//registers the just-spawned targetPieces to the target_logic_script
	//so that they may be deleted on hit.
	local logic_script_handle = entities["target_logic_script"]
	EntFireByHandle(logic_script_handle,
		"RunScriptCode",
		"saveLocation(" + lastCreatedU + "," + lastCreatedVert + ")",
		0,
		activator,
		self
	)
	foreach( targetname, handle in entities )
	{
		if(targetname != "target_logic_script")
			EntFireByHandle(logic_script_handle, "RunScriptCode", "register()", 0, activator, handle)
	}
}