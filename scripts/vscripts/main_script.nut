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

function enableCheats(){
	if(!cheatsOn){
		local command = "sv_cheats 1"
		EntFire("point_clientcommand", "command", command, -1, activator)
		cheatsOn = true
	}
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

function restartGame(){
	local command = "mp_restartgame_immediate 1"
	EntFire("point_clientcommand", "command", command, -1, activator)
	EntFire("start_sound", "PlaySound", "")
}

function togglePrecision(){
	enableCheats()
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
	enableCheats()
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

MAX_ZOOM_COUNT <- 6
zoom_array <- []
function debug()
{
	for(local k = 0; k < MAX_ZOOM_COUNT; k++)
		zoom_array.append(null)
	local fileContents = FileToString("tr_vertshot.cfg")
	if(fileContents == null) {
		printl("[WARNING] tr_vertshot.cfg not found. Disabling zoom buttons.")
		return
	}
	local lineArray = split(fileContents, "\n")
	for(local k = 0; k < lineArray.len(); k++){
		if (k >= MAX_ZOOM_COUNT){
			printl("[WARNING] " + lineArray.len() + " zoom settings found. Using first " + MAX_ZOOM_COUNT)
			break
		}
		local wordArray = split(lineArray[k], ",")
		local fov
		local sens
		try {
			fov = wordArray[1].tofloat()
			sens = wordArray[2].tofloat()
		}
		catch(e){
			printl("[ERROR] Could not read line \"" + lineArray[k] + "\"")
			printl("[ERROR] Must have format \"<string>,<positive decimal>,<positive decimal>\"")
			continue
		}
		EntFire("zoom_" + k + "_worldtext", "AddOutput", "message " + wordArray[0])
		zoom_array[k] = {fov=fov,sens=sens}
	}
}

unselected_color <- "133 135 120"
selected_color <- "255 128 0"
prevZoomIndex <- "default"
default_fov <- Convars.GetFloat("fov_desired")
default_sens <- Convars.GetFloat("sensitivity")
function zoomBind(index){
	if(index >= zoom_array.len() || zoom_array[index] == null){
		EntFire("target_sound_miss", "PlaySound", "")
		return
	}
	EntFire("start_sound", "PlaySound", "")
	if(index.tostring() == prevZoomIndex)
		return
	enableCheats()
	local fov = zoom_array[index].fov
	local sens = zoom_array[index].sens
	local command = "alias \"togglezoom\" \"zoomin\"; alias \"zoomin\" \"alias togglezoom zoomout; fov " +
			fov + "; sensitivity " + sens + "\"; alias \"zoomout\" \"alias togglezoom zoomin; fov " + default_fov +
			"; sensitivity " + default_sens + "\"; bind mouse2 togglezoom"
	EntFire("point_clientcommand", "command", command, -1, activator)
	setTargetBounds(fov)
	EntFire("zoom_" + index + "_worldtext", "SetColor", selected_color)
	EntFire("zoom_" + prevZoomIndex + "_worldtext", "SetColor", unselected_color)
	prevZoomIndex <- index.tostring()
}

function defaultZoomBind(){
	EntFire("start_sound", "PlaySound", "")
	if(prevZoomIndex == "default")
		return
	local command = "fov_desired " + default_fov +
		"; sensitivity " + default_sens +
		"; bind mouse2 " + default_mouse2
	EntFire("point_clientcommand", "command", command, -1, activator)
	setTargetBounds(default_fov)
	EntFire("zoom_default_worldtext", "SetColor", selected_color)
	EntFire("zoom_" + prevZoomIndex + "_worldtext", "SetColor", unselected_color)
	prevZoomIndex <- "default"
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
function zoom_bind_helper(sens, fov){
	enableCheats()
	local command = "alias \"togglezoom\" \"zoomin\"; alias \"zoomin\" \"alias togglezoom zoomout; fov " +
			fov + "; sensitivity " + sens + "\"; alias \"zoomout\" \"alias togglezoom zoomin; fov " + DEFAULT_SOURCE_FOV +
			"; sensitivity " + DEFAULT_SENS + "\"; bind mouse2 togglezoom"
	EntFire("point_clientcommand", "command", command, -1, activator)
	setTargetBounds(fov)
	EntFire("start_sound", "PlaySound", "")
	
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
	zoom_bind_helper(0.485318, 51.774009)
	swapBoundsText("owAshe_worldtext", "Ow Ashe zoom")
}
function apex1xZoom(){
	zoom_bind_helper(0.797473, 77.14284)
	swapBoundsText("apex1x_worldtext", "Apex 1x zoom")
}
function apexRifleZoom(){
	zoom_bind_helper(0.709538, 70.71427)
	swapBoundsText("apexRifle_worldtext", "Apex Rifle zoom")
}
function apex2xZoom(){
	zoom_bind_helper(0.462241, 49.616585)
	swapBoundsText("apex2x_worldtext", "Apex 2x zoom")
}