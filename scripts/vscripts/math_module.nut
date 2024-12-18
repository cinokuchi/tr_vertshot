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

//scale factors are arbitrary and are just to force a narrower spawn area
VERT_SCALE_FACTOR <- 2.0/5
HORZ_SCALE_FACTOR <- 2.0/5
/*
	Takes degrees and returns radians
	This formula calculates the VFOV, then
		divides by 2 to get offset from screen middle to screen top/bottom
*/
function getVertOffsetFromSourceFOV(sourceFOV){
	return atan((9.0/12) * tan(deg2Rad(sourceFOV/2)) * VERT_SCALE_FACTOR)
}
/*
	Takes degrees and returns radians
	This formula calculates the HFOV,
		divides by 2 to get offset from screen middle to screen left/right.
*/
function getHorzOffsetFromSourceFOV(sourceFOV){
	return atan((16.0/12) * tan(deg2Rad(sourceFOV/2)) * HORZ_SCALE_FACTOR)
}

QUARTER_OF_PI <- deg2Rad(45)
/*
	Takes degrees and returns hammer units.
	Given an FOV, returns a target distance to keep
		apparent size roughly the same.
	240 and QUARTER_OF_PI are arbitrary - I decided
		240 hammer units of distance when source FOV is 90 deg (half of default fov is 45) and target diameter is 32 to be good numbers
*/
function getRhoFromSourceFOV(sourceFOV){
    return 240 * tan(QUARTER_OF_PI)/(tan(deg2Rad(sourceFOV)/2))
}