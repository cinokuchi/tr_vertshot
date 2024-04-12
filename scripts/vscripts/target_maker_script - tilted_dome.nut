m_hSpawner <- Entities.CreateByClassname("env_entity_maker")
m_hSpawner.__KeyValueFromString( "EntityTemplate", "targetTemplate")

//Approximate headposition standing on edge of platform.
TARGET_ORIGIN <- Vector(640, 0, 1090)

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

//Provides a random theta angle in the legal bounds, in radians.
//Technically angle = 0 is twice as likely as the rest
function getRandomTheta(){
	return RandomFloat(0, 2*PI)
}

//Provides a random phi angle in the legal bounds, in radians.
//Not tilted yet.
//Normalized so that the entire dome has the same target density per area
U_MAX <- -cos(deg2Rad(82.5))
function getRandomPhi(){
	local u = RandomFloat(-1, U_MAX)
	return acos(-u)
}

//Uses mathematics convention
//returns a vector
function sphericalToCartesian(rho, theta, phi)
{
	local sin_phi = sin(phi)
	return Vector(rho*sin_phi*cos(theta), rho*sin_phi*sin(theta), rho*cos(phi))
}

//Tilts the dome slightly so its higher in the back and lower in the front
TILT_ANGLE <- deg2Rad(-52.5)
COS_TILT <- cos(TILT_ANGLE)
SIN_TILT <- sin(TILT_ANGLE)
function tilt(untilted)
{
	return Vector(
			untilted.x*COS_TILT + untilted.z*SIN_TILT,
			untilted.y,
			untilted.z*COS_TILT - untilted.x*SIN_TILT)
}

function makeTarget(rho)
{
	local position = tilt(sphericalToCartesian(rho, getRandomTheta(), getRandomPhi()))
	//acos only returns positive
	local phi = getSign(position.x) * rad2Deg(acos(position.z/rho))
	local theta = position.x == 0 ? getSign(position.y) * 90 : rad2Deg(atan(position.y/position.x))
	local direction = Vector(
			phi,
			theta,
			0)
	m_hSpawner.SpawnEntityAtLocation(position + TARGET_ORIGIN, direction)
}