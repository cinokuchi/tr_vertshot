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
function getHorzFromU(uAngle){
	return asin(uAngle)
}

function getUFromHorz(horz){
	return sin(horz)
}

//---------------------------------------------------------------------------------------------------------------------------
m_hSpawner <- Entities.CreateByClassname("env_entity_maker")
m_hSpawner.__KeyValueFromString( "EntityTemplate", "targetTemplate")

//Approximate headposition standing on edge of platform.
TARGET_ORIGIN <- Vector(536, 0, 1090)

rho <- 0
lastDestroyedU <- 0.0
lastDestroyedVert <- 0.0
uBounds <- 0.0
vertBounds <- 0.0

//------------------------------------------------------------------------------------------------------------------------
function setRho(newRho){
	rho = newRho
}

function setHorzBounds(newHorzBounds){
	uBounds = getUFromHorz(newHorzBounds)
}

function setVertBounds(newVertBounds){
	vertBounds = newVertBounds
}

function setLastTargetLocation(uAngle, vertAngle){
	lastDestroyedU = uAngle
	lastDestroyedVert = vertAngle
	//printl("lastHorz: " + lastDestroyedU + "; lastDestroyedVert: " + lastDestroyedVert)
}

//Provides a random u angle in the legal bounds, in radians.
function getRandomU(){
	return RandomFloat(max(-uBounds, lastDestroyedU - uBounds), min(uBounds, lastDestroyedU + uBounds))
}

//Provides a random vert angle in the legal bounds, in radians.
//Normalized so that the spawn area has the same amount of targets per area
VERT_MIN <- deg2Rad(-50)
VERT_MAX <- deg2Rad(90)
function getRandomVert(){
	return RandomFloat(max(VERT_MIN, lastDestroyedVert - vertBounds), min(VERT_MAX, lastDestroyedVert + vertBounds))
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
	//printl("maker.makeTarget() - lastCreatedU: " + lastCreatedU + "; lastCreatedVert: " + lastCreatedVert)
	m_hSpawner.SpawnEntityAtLocation(position + TARGET_ORIGIN, direction)
}

function sendLocation(){
	EntFireByHandle(activator, "RunScriptCode", "saveLocation(" + lastCreatedU + "," + lastCreatedVert + ")", 0, self, self)
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