MAX_TARGET_COUNT <- 10
targetCount <- 0
zero_hit_count <- 0
first_hit_count <- 0
second_hit_count <- 0
third_hit_count <- 0
total_hit_count <- 0

isOn <- false

cheatsOn <- false
hasPrecision <- false
hasRefillOnKill <- false

DEFAULT_SENS <- 1
DEFAULT_SOURCE_FOV <- 90

//---------------------------------------------------------------------------------------------------------------------------

function rad2Deg(rad)
{
	return rad / PI * 180
}
function deg2Rad(deg)
{
	return deg / 180.0 * PI
}

//Takes degrees and returns radians
//This formula calculates the VFOV,
//divides by 2 to get offset from screen middle to screen top/bottom,
//then divides by 2 again because my wrist hurts from these flicks bro.
function getVertBoundsFromSourceFOV(sourceFOV){
	return atan(3 * tan(deg2Rad(sourceFOV/2)) / 4) / 2
}

//Takes degrees and returns radians
//This formula calculates the HFOV,
//divides by 2 to get offset from screen middle to screen left/right,
//then divides by 2 again because my wrist hurts from these flicks bro.
function getHorzBoundsFromSourceFOV(sourceFOV){
	return atan(4 * tan(deg2Rad(sourceFOV/2)) / 3) / 2
}

//Takes degrees and returns hammer units
DEFAULT_SOURCE_FOV_RADS <- deg2Rad(DEFAULT_SOURCE_FOV)
function getRhoFromSourceFOV(sourceFOV){
	return 32 / tan(atan(1.0/20.0) * deg2Rad(sourceFOV)/DEFAULT_SOURCE_FOV_RADS)
}

//---------------------------------------------------------------------------------------------------------------------------


function spawnTarget()
{
	if(targetCount >= MAX_TARGET_COUNT - 1)
	{
		isOn = false
		stopSession()
		return
	}
	targetCount = targetCount + 1
	EntFire("target_maker_logic_script", "RunScriptCode", "makeTarget()")
}

function getHit(index)
{
	local targetName = ""
	local hitCount = 0
	local timeExtension = 0.0
	if(index == 0) {
		targetName = "zero_ring_hit_count_worldtext"
		hitCount = zero_hit_count = zero_hit_count + 1
		timeExtension = 0.18
	}
	else if(index == 1) {
		targetName = "first_ring_hit_count_worldtext"
		hitCount = first_hit_count = first_hit_count + 1
		timeExtension = 0.16
	}
	else if(index == 2) {
		targetName = "second_ring_hit_count_worldtext"
		hitCount = second_hit_count = second_hit_count + 1
		timeExtension = 0.14
	}
	else if(index == 3) {
		targetName = "third_ring_hit_count_worldtext"
		hitCount = third_hit_count = third_hit_count + 1
		timeExtension = 0.12
	}
	EntFire(targetName, "AddOutput", "message " + hitCount)
	EntFire("target_timer", "AddToTimer", "" + timeExtension)
	
	total_hit_count = total_hit_count + 1
	EntFire("total_hit_count_worldtext", "AddOutput", "message " + total_hit_count)
	
	targetCount = targetCount - 1

	if(hasRefillOnKill){
		local command = "impulse 101"
		EntFire("point_clientcommand", "command", command, -1, activator)
	}
}

function startSession()
{
	//reset hit counts
	//don't want to do this when the session ends so that the player can review results
	zero_hit_count = 0
	EntFire("zero_ring_hit_count_worldtext", "AddOutput", "message 0")
	first_hit_count = 0
	EntFire("first_ring_hit_count_worldtext", "AddOutput", "message 0")
	second_hit_count = 0
	EntFire("second_ring_hit_count_worldtext", "AddOutput", "message 0")
	third_hit_count = 0
	EntFire("third_ring_hit_count_worldtext", "AddOutput", "message 0")
	total_hit_count = 0
	EntFire("total_hit_count_worldtext", "AddOutput", "message 0")
	
	EntFire("start_sound", "PlaySound", "")
	EntFire("target_timer", "Enable", "")
	EntFire("button_worldtext", "AddOutput", "message STOP")
}

function stopSession()
{
	targetCount = 0
	EntFire("target_timer", "Disable", "")
	EntFire("target_logic_script*", "RunScriptCode", "destroyTarget()")
	EntFire("stop_sound", "PlaySound", "")
	EntFire("button_worldtext", "AddOutput", "message PLAY")
	EntFire("target_maker_logic_script", "RunScriptCode", "setLastTargetLocation(0,0)")
}

function toggleSession()
{
	isOn = !isOn
	if(isOn)
		startSession()
	else
		stopSession()
}

function togglePrecision(){
	if(!cheatsOn){
		local command = "sv_cheats 1"
		EntFire("point_clientcommand", "command", command, -1, activator)
		cheatsOn = true
	}
	if(hasPrecision){
		local command = "removecond 96"
		EntFire("point_clientcommand", "command", command, -1, activator)
		EntFire("precision_worldtext", "AddOutput", "message Precision: OFF")
		hasPrecision = false
		EntFire("stop_sound", "PlaySound", "")
	}
	else{
		local command = "addcond 96"
		EntFire("point_clientcommand", "command", command, -1, activator)
		EntFire("precision_worldtext", "AddOutput", "message Precision: ON")
		hasPrecision = true
		EntFire("start_sound", "PlaySound", "")
	}
}

function toggleRefillOnKill(){
	if(!cheatsOn){
		local command = "sv_cheats 1"
		EntFire("point_clientcommand", "command", command, -1, activator)
		cheatsOn = true
	}
	if(hasRefillOnKill){
		EntFire("refillOnKill_worldtext", "AddOutput", "message Refill On Kill: OFF")
		hasRefillOnKill = false
		EntFire("stop_sound", "PlaySound", "")
	}
	else{
		EntFire("refillOnKill_worldtext", "AddOutput", "message Refill On Kill: ON")
		hasRefillOnKill = true
		EntFire("start_sound", "PlaySound", "")
	}
}
 
function debug()
{
	printl("helloworld")
}

function setTargetBounds(fov){
	local newRho = getRhoFromSourceFOV(fov)
	local newVertBounds = getVertBoundsFromSourceFOV(fov)
	local newHorzBounds = getHorzBoundsFromSourceFOV(fov)
	EntFire("target_maker_logic_script", "RunScriptCode", "setRho(" + newRho + ")")
	EntFire("target_maker_logic_script", "RunScriptCode", "setVertBounds(" + newVertBounds + ")")
	EntFire("target_maker_logic_script", "RunScriptCode", "setHorzBounds(" + newHorzBounds + ")")
}

//fov is in degrees, measured as 4:3 horz aspect ratio.
function zoom_bind(sens, fov){
	local command = "alias \"togglezoom\" \"zoomin\"; alias \"zoomout\" \"alias togglezoom zoomin; fov " +
			fov + "; sensitivity " + sens + "\"; alias \"zoomin\" \"alias togglezoom zoomout; fov " + DEFAULT_SOURCE_FOV +
			"; sensitivity " + DEFAULT_SENS + "\"; bind mouse2 togglezoom"
	EntFire("point_clientcommand", "command", command, -1, activator)
	setTargetBounds(fov)
}

lastBoundsLabel <- "hipfire_worldtext"
lastBoundsDesc <- "Hipfire Bounds: "
function swapBoundsText(label, description){
	EntFire(lastBoundsLabel, "AddOutput", "message " + lastBoundsDesc + ": OFF")
	EntFire(label, "AddOutput", "message " + description + ": ON")
	lastBoundsLabel = label
	lastBoundsDesc = description
}

function hipfireBounds(){
	setTargetBounds(DEFAULT_SOURCE_FOV)
	swapBoundsText("hipfire_worldtext", "Hipfire bounds")
	EntFire("start_sound", "PlaySound", "")
}
function owAsheZoom(){
	zoom_bind(0.485318, 51.774009)
	swapBoundsText("owAshe_worldtext", "Ow Ashe zoom")
	EntFire("start_sound", "PlaySound", "")
}
function apex1xZoom(){
	zoom_bind(0.797473, 77.14284)
	swapBoundsText("apex1x_worldtext", "Apex 1x zoom")
	EntFire("start_sound", "PlaySound", "")
}
function apexRifleZoom(){
	zoom_bind(0.709538, 70.71427)
	swapBoundsText("apexRifle_worldtext", "Apex Rifle zoom")
	EntFire("start_sound", "PlaySound", "")
}
function apex2xZoom(){
	zoom_bind(0.462241, 49.616585)
	swapBoundsText("apex2x_worldtext", "Apex 2x zoom")
	EntFire("start_sound", "PlaySound", "")
}