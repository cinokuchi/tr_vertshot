MAX_TARGET_COUNT <- 10
targetCount <- 0
zero_hit_count <- 0
first_hit_count <- 0
second_hit_count <- 0
third_hit_count <- 0
total_hit_count <- 0

isOn <- false

hasPrecision <- false
hasRefillOnKill <- false

unselected_color <- "133 135 120"
selected_color <- "255 128 0"
prevZoomIndex <- "default"
default_fov <- 0.0
default_sens <- 0.0

MAX_ZOOM_COUNT <- 6
zoom_array <- []

//---------------------------------------------------------------------------------------------------------------------------

function rad2Deg(rad)
{
	return rad / PI * 180
}
function deg2Rad(deg)
{
	return deg / 180.0 * PI
}

/*
	Takes degrees and returns radians
	This formula calculates the VFOV, then
		divides by 2 to get offset from screen middle to screen top/bottom
*/
function getVertBoundsFromSourceFOV(sourceFOV){
	return atan(3 * tan(deg2Rad(sourceFOV/2)) / 4)
}

/*
	Takes degrees and returns radians
	This formula calculates the HFOV,
		divides by 2 to get offset from screen middle to screen left/right,
		and divides by 2 again just to force a more narrow spawn area.
*/
function getHorzBoundsFromSourceFOV(sourceFOV){
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

//Read in zoom values from file
function initZoomBinds()
{
	//get current fov and sensitivity, use as default
	default_fov = Convars.GetFloat("fov_desired")
	default_sens = Convars.GetFloat("sensitivity")
	
	//initialize zoom_array.
	for(local k = 0; k < MAX_ZOOM_COUNT; k++)
		zoom_array.append(null)
		
	//load file
	local fileContents = FileToString("tr_vertshot.cfg")
	if(fileContents == null) {
		printl("[WARNING] tr_vertshot.cfg not found. Disabling zoom buttons.")
		return
	}
	
	//parse file
	local lineArray = split(fileContents, "\n")
	for(local k = 0; k < lineArray.len(); k++){
	
		//Ignore excess zoom settings
		if (k >= MAX_ZOOM_COUNT){
			printl("[WARNING] " + lineArray.len() + " zoom settings found. Using first " + MAX_ZOOM_COUNT)
			break
		}
		
		//read in fov and sens
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
		
		//set labels, fov, and sens
		EntFire("zoom_" + k + "_worldtext", "AddOutput", "message " + wordArray[0])
		zoom_array[k] = {fov=fov,sens=sens}
	}
	
	//Initializes target bounds based off of hipfire fov
	setTargetBounds(default_fov)
}

function debug(){
	printl("debug fired")
}

//Select a zoom bind
function zoomBind(index){

	//if this zoom bind is unset, play invalid sound and do nothing
	if(index >= zoom_array.len() || zoom_array[index] == null){
		EntFire("target_sound_miss", "PlaySound", "")
		return
	}
	
	//otherwise, play select sound
	EntFire("start_sound", "PlaySound", "")
	
	//if re-selecting already selected option, do nothing
	if(index.tostring() == prevZoomIndex)
		return
		
	//set up aliases and bind mouse2 to zoom
	local fov = zoom_array[index].fov
	local sens = zoom_array[index].sens
	local command = "alias \"togglezoom\" \"zoomin\"; alias \"zoomin\" \"alias togglezoom zoomout; fov " +
			fov + "; sensitivity " + sens + "\"; alias \"zoomout\" \"alias togglezoom zoomin; fov " + default_fov +
			"; sensitivity " + default_sens + "\"; bind mouse2 togglezoom"
	EntFire("point_clientcommand", "command", command, -1, activator)
	
	//Scale target distance and spawn offsets based off of fov
	setTargetBounds(fov)
	
	//Highlight selected zoom option
	EntFire("zoom_" + index + "_worldtext", "SetColor", selected_color)
	EntFire("zoom_" + prevZoomIndex + "_worldtext", "SetColor", unselected_color)
	
	//Remember last highlighted zoom option
	prevZoomIndex <- index.tostring()
}

//De-select zoom bind
function defaultZoomBind(){
	EntFire("start_sound", "PlaySound", "")
	if(prevZoomIndex == "default")
		return
	local command = "fov_desired " + default_fov +
		"; sensitivity " + default_sens +
		"; unbind mouse2"
	EntFire("point_clientcommand", "command", command, -1, activator)
	setTargetBounds(default_fov)
	EntFire("zoom_default_worldtext", "SetColor", selected_color)
	EntFire("zoom_" + prevZoomIndex + "_worldtext", "SetColor", unselected_color)
	prevZoomIndex <- "default"
}

//Scale target distance and spawn offsets based off of fov
function setTargetBounds(fov){
	local newRho = getRhoFromSourceFOV(fov)
	local newVertBounds = getVertBoundsFromSourceFOV(fov)
	local newHorzBounds = getHorzBoundsFromSourceFOV(fov)
	EntFire("target_maker_logic_script", "RunScriptCode", "setRho(" + newRho + ")")
	EntFire("target_maker_logic_script", "RunScriptCode", "setVertBounds(" + newVertBounds + ")")
	EntFire("target_maker_logic_script", "RunScriptCode", "setHorzBounds(" + newHorzBounds + ")")
}