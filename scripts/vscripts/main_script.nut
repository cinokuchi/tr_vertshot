IncludeScript("button_module.nut")

MAX_TARGET_COUNT <- 5
targetCount <- 0
zero_hit_count <- 0
first_hit_count <- 0
second_hit_count <- 0
third_hit_count <- 0
total_hit_count <- 0

default_fov <- 0
default_sens <- 0.0

MAX_ZOOM_COUNT <- 6
zoom_array <- []
bind_array <- ["]", "[", "p", "o", "i", "l", "k"]

Convars.SetValue("mp_waitingforplayers_time", "0")
//---------------------------------------------------------------------------------------------------------------------------

hasEnabledCheats <- false
function enableCheats(){
	if(!hasEnabledCheats){
		EntFire("point_clientcommand", "command", "sv_cheats 1", -1, activator)
		hasEnabledCheats = true
	}
}

//---------------------------------------------------------------------------------------------------------------------------
//    Autoplay button
//---------------------------------------------------------------------------------------------------------------------------
class AutoplayToggle extends CheckmarkButton{
    constructor(){
        base.constructor("autoplay")
    }

    function select(){
        base.select()
        EntFire("autoplay_worldtext", "AddOutput", "message autoplay: on")
    }
    function deselect(){
        base.deselect()
        EntFire("autoplay_worldtext", "AddOutput", "message autoplay: off")
    }
}
autoplayToggle <- AutoplayToggle()
function toggleAutoplay(){
    if(currState == AUTOPLAYCOUNTDOWN){
        stateChange(HARDSTOP)
    }
    autoplayToggle.toggle()
}

//---------------------------------------------------------------------------------------------------------------------------
//    Session button
//---------------------------------------------------------------------------------------------------------------------------
HARDSTOP <- 0
INPROGRESS <- 1
AUTOPLAYCOUNTDOWN <- 2
currState <- HARDSTOP

function setAllBackwallWorldtexts(color){
    EntFire("total_hit_count_worldtext", "SetColor", color)
    EntFire("zero_ring_hit_count_worldtext", "SetColor", color)
    EntFire("first_ring_hit_count_worldtext", "SetColor", color)
    EntFire("second_ring_hit_count_worldtext", "SetColor", color)
    EntFire("third_ring_hit_count_worldtext", "SetColor", color)
    EntFire("total_label_worldtext", "SetColor", color)
    EntFire("zero_ring_label_worldtext", "SetColor", color)
    EntFire("first_ring_label_worldtext", "SetColor", color)
    EntFire("second_ring_label_worldtext", "SetColor", color)
    EntFire("third_ring_label_worldtext", "SetColor", color)
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
	
    //make all the text on the back wall partially see through
    local color = "255 255 255 125"
    setAllBackwallWorldtexts(color)
    
	EntFire("start_sound", "PlaySound", "")
	EntFire("target_timer", "Enable", "")
	EntFire("play_worldtext", "AddOutput", "message STOP")
}
  
function stopSession()
{
	targetCount = 0
	EntFire("target_timer", "Disable", "")
	EntFire("maker_logic_script", "RunScriptCode", "resetTargets()")
    
    //make all the text on the back wall visible
    local color = "255 255 255 255"
    setAllBackwallWorldtexts(color)
}

function stateChange(newState){
    if(currState == newState){
        printl("[WARNING] should be impossible to transition from " + newState + " back to same state")
    }

    //clean up old state
    if(currState == HARDSTOP){
        EntFire("maker_logic_script", "RunScriptCode", "deleteFloatingPlay()")
    }
    else if(currState == INPROGRESS){
        stopSession()
    }
    else if(currState == AUTOPLAYCOUNTDOWN){
        EntFire("maker_logic_script", "RunScriptCode", "stopAutoplayCountdown()")
    }
    
    //start new state
    if(newState == HARDSTOP){
        EntFire("maker_logic_script", "RunScriptCode", "makeFloatingPlay()")
        EntFire("stop_sound", "PlaySound", "")
        EntFire("play_worldtext", "AddOutput", "message START")
    }
    else if(newState == INPROGRESS){
        startSession()
    }
    else if(newState == AUTOPLAYCOUNTDOWN){
        if(currState == HARDSTOP){
            printl("[WARNING] should be impossible to transition from hardstop to AUTOPLAYCOUNTDOWN")
        }
        EntFire("stop_sound", "PlaySound", "")
        EntFire("maker_logic_script", "RunScriptCode", "startAutoplayCountdown()")
        EntFire("play_worldtext", "AddOutput", "message STOP")
    }
    
    currState = newState
}

function togglePlay(){
    if(currState == INPROGRESS || currState == AUTOPLAYCOUNTDOWN){
        stateChange(HARDSTOP)
    }
    else if(currState == HARDSTOP){
        stateChange(INPROGRESS)
    }
}

function autoplayTimerTimeout(){
    stateChange(INPROGRESS)
}

function spawnTarget()
{
	if(targetCount >= MAX_TARGET_COUNT - 1)
	{
        if(autoplayToggle.getSelected()){
            stateChange(AUTOPLAYCOUNTDOWN)
        }
        else{
            stateChange(HARDSTOP)
        }
		return
	}
	targetCount = targetCount + 1
	EntFire("maker_logic_script", "RunScriptCode", "makeTarget()")
}

//---------------------------------------------------------------------------------------------------------------------------
//    Restart button
//---------------------------------------------------------------------------------------------------------------------------
function restartGame(){
	local command = "mp_restartgame_immediate 1"
	EntFire("point_clientcommand", "command", command, -1, activator)
	EntFire("start_sound", "PlaySound", "")
}


//---------------------------------------------------------------------------------------------------------------------------
//    Spawn type button
//---------------------------------------------------------------------------------------------------------------------------

class SpawnSelector extends RadioButton{
    function select(index){
        //Two of the indices have subtitles that need to be dealt with separately
        if(getSelected() == 0 && index != 0){
            EntFire("random_angle_worldtext", "SetColor", unselected_color)
        }
        else if(getSelected() == 1 && index != 1){
            EntFire("window_angle_worldtext", "SetColor", unselected_color)
        }
        
        if(index == 0){
            EntFire("random_angle_worldtext", "SetColor", selected_color)
        }
        else if(index == 1){
            EntFire("window_angle_worldtext", "SetColor", selected_color)
        }
        
        base.select(index)
    }
}
spawnSelector <- SpawnSelector(["spawn_random", "spawn_windowed", "spawn_walking", "spawn_nearby"])

function setSpawnNearby(){
    spawnSelector.select(3)
	EntFire("maker_logic_script", "RunScriptCode", "setSpawnNearby()")
}
function setSpawnWalking(){
    spawnSelector.select(2)
	EntFire("maker_logic_script", "RunScriptCode", "setSpawnWalking()")
}
function setSpawnWindowed(){
    spawnSelector.select(1)
	EntFire("maker_logic_script", "RunScriptCode", "setSpawnWindowed()")
}
function setSpawnRandom(){
    spawnSelector.select(0)
	EntFire("maker_logic_script", "RunScriptCode", "setSpawnRandom()")
}

//TODO: get rid of these callbacks and do everything in the main script
function moveWindowSuccess(window_vert_angle){
	EntFire("start_sound", "PlaySound", "")
    EntFire("window_angle_worldtext", "AddOutput", "message " + window_vert_angle + " degrees")
}
function moveWindowSilent(window_vert_angle){
    EntFire("window_angle_worldtext", "AddOutput", "message " + window_vert_angle + " degrees")
}
function moveWindowFailure(){
	EntFire("target_sound_miss", "PlaySound", "")
}

function randomizeWindowSuccess(random_vert_angle){
	EntFire("start_sound", "PlaySound", "")
    EntFire("random_angle_worldtext", "AddOutput", "message " + random_vert_angle + " degrees")
}
function randomizeWindowSilent(random_vert_angle){
    EntFire("random_angle_worldtext", "AddOutput", "message " + random_vert_angle + " degrees")
}
function randomizeWindowFailure(){
	EntFire("target_sound_miss", "PlaySound", "")
}

//---------------------------------------------------------------------------------------------------------------------------
// target size
//---------------------------------------------------------------------------------------------------------------------------
targetSizeSelector <- RadioButton(["big_targets", "small_targets", "tiny_targets"])

function setBigTargets(){
    targetSizeSelector.select(0)
	EntFire("maker_logic_script", "RunScriptCode", "setBigTargets()")
}
function setSmallTargets(){
    targetSizeSelector.select(1)
	EntFire("maker_logic_script", "RunScriptCode", "setSmallTargets()")
}
function setTinyTargets(){
    targetSizeSelector.select(2)
	EntFire("maker_logic_script", "RunScriptCode", "setTinyTargets()")
}

//---------------------------------------------------------------------------------------------------------------------------
// Precision and RefillOnKill
//---------------------------------------------------------------------------------------------------------------------------
class PrecisionToggle extends CheckmarkButton{
    function select(){
        base.select()
		EntFire("point_clientcommand", "command", "addcond 96", -1, activator)
    }
    function deselect(){
        base.deselect()
		EntFire("point_clientcommand", "command", "removecond 96", -1, activator)
    }
}
precisionToggle <- PrecisionToggle("precision")
function togglePrecision(){
    enableCheats()
    precisionToggle.toggle()
}

refillOnKillToggle <- CheckmarkButton("refillOnKill")
function toggleRefillOnKill(){
    enableCheats()
    refillOnKillToggle.toggle()
}

function getHit(index)
{
	local targetName = ""
	local hitCount = 0
	if(index == 0) {
		targetName = "zero_ring_hit_count_worldtext"
		hitCount = zero_hit_count = zero_hit_count + 1
	}
	else if(index == 1) {
		targetName = "first_ring_hit_count_worldtext"
		hitCount = first_hit_count = first_hit_count + 1
	}
	else if(index == 2) {
		targetName = "second_ring_hit_count_worldtext"
		hitCount = second_hit_count = second_hit_count + 1
	}
	else if(index == 3) {
		targetName = "third_ring_hit_count_worldtext"
		hitCount = third_hit_count = third_hit_count + 1
	}
	EntFire(targetName, "AddOutput", "message " + hitCount)
	
	total_hit_count = total_hit_count + 1
	EntFire("total_hit_count_worldtext", "AddOutput", "message " + total_hit_count)
	
	targetCount = targetCount - 1

	if(refillOnKillToggle.getSelected()){
		local command = "impulse 101"
		EntFire("point_clientcommand", "command", command, -1, activator)
	}
}

//---------------------------------------------------------------------------------------------------------------------------
// Zoombinds
//---------------------------------------------------------------------------------------------------------------------------
zoomSelector <- null

//Need to call setFov or else everything breaks
//I would do this in a try-finally but squirrel doesn't have finally
//so here's my workaround
function initZoomBindsHelper(){
    /*
        Hipfire is necessary to use zooms - if the hipfire file doesn't exist, don't do the zooms
    */
    
	//load file
	local fileContents = FileToString("tr_vertshot_hipfire.cfg")
	if(fileContents == null) {
		printl("[WARNING] tr_vertshot_hipfire.cfg not found. Disabling zoom buttons.")
		return
	}

	//initialize zoom_array.
    //MAX_ZOOM_COUNT + 1 as we are putting the hipfire into the zoom_array as well
	for(local k = 0; k < MAX_ZOOM_COUNT + 1; k++)
		zoom_array.append(null)

	//get current fov and sensitivity, use as default
    local wordArray = split(fileContents, ",")
    try {
        default_fov = wordArray[0].tointeger()
        default_sens = wordArray[1].tofloat()
    }
    catch(e){
        printl("[ERROR] Could not parse \"" + fileContents + "\"")
        printl("[ERROR] Must have format \"<positive integer (fov)>,<positive decimal (sens)>\"")
        return
    }
    zoom_array[0] = {fov=default_fov,sens=default_sens,name="Restore Default FOV and Sens"}
	
    /*
        Hipfire set, now we can register the zooms
    */
	//load file
	fileContents = FileToString("tr_vertshot_zooms.cfg")
	if(fileContents == null) {
		printl("[WARNING] tr_vertshot_zooms.cfg not found. Disabling zoom buttons.")
		return
	}
	
	//parse file
	local lineArray = split(fileContents, "\n")
    local labelArray = ["zoom_0"]
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
			fov = wordArray[1].tointeger()
			sens = wordArray[2].tofloat()
		}
		catch(e){
			printl("[ERROR] Could not parse line \"" + lineArray[k] + "\"")
			printl("[ERROR] Must have format \"<string>,<positive int (fov)>,<positive decimal (sens)>\"")
			continue
		}
		
		//set labels, fov, and sens
		EntFire("zoom_" + (k+1) + "_worldtext", "AddOutput", "message " + wordArray[0])
		zoom_array[k+1] = {fov=fov,sens=sens,name=wordArray[0]}
        labelArray.append("zoom_" + (k+1))
	}
    
    //Set up button objects
    if(zoom_array.len() > 0){
        zoomSelector = RadioButton(labelArray)
    }
}

//Read in zoom values from file
function initZoomBinds()
{
    //needs some default_fov to calculate target sizes
    default_fov = 90
	
    initZoomBindsHelper()
    
	//Initializes target bounds based off of hipfire fov
	EntFire("maker_logic_script", "RunScriptCode", "setFov(" + default_fov + ")")
}

//Select a zoom bind
function zoomBind(index){
	//if this zoom bind is unset, play invalid sound and do nothing
	if(index >= zoom_array.len() || zoom_array[index] == null){
		EntFire("target_sound_miss", "PlaySound", "")
		return
	}

    //highlight the selected zoom
    local prevSelected = zoomSelector.getSelected()
    zoomSelector.select(index)
    
    //if we didn't switch the selection we can stop here
    if(prevSelected == index){
        return
    }

	enableCheats()
	//set up aliases and bind mouse2 to zoom
	local fov = zoom_array[index].fov
	local sens = zoom_array[index].sens
	local command = "alias \"togglezoom\" \"zoomin\"; alias \"zoomin\" \"alias togglezoom zoomout; fov " +
			fov + "; sensitivity " + sens + "\"; alias \"zoomout\" \"alias togglezoom zoomin; fov " + default_fov +
			"; sensitivity " + default_sens + "\"; bind mouse2 togglezoom"
	EntFire("point_clientcommand", "command", command, -1, activator)
	
	//Scale target distance and spawn offsets based off of fov
	EntFire("maker_logic_script", "RunScriptCode", "setFov(" + fov + ")")
}

//print zoombind commands to console so the user can copy paste them.
function printZoomBinds(){
    printl("Copy the following console commands and either:")
    printl("\t1. Run them directly in the console")
    printl("\t2. Put them into autoexec.cfg to run them before every game (not recommended)")
    printl("\t3. Create a new .cfg file, put them in there, and run that .cfg file upon entering this map")
    printl("alias \"togglezoom\" \"zoomin\";\nalias \"zoomin\" \"alias togglezoom zoomout\";\nalias \"zoomout\" \"alias togglezoom zoomin; fov " + default_fov + "; sensitivity " + default_sens + "\";\nbind mouse2 togglezoom;")

    //skip the first zoom bind because that one is just the defaults
    for(local k = 1; k <= MAX_ZOOM_COUNT; k++){
        if(zoom_array[k] == null){
            break;
        }
        local label = "zoom" + k
        local fov = zoom_array[k].fov
        local sens = zoom_array[k].sens
        local button = bind_array[k]
        local name = zoom_array[k].name
        printl("alias \"" + label + "\" \"alias togglezoom zoomout; fov " + fov + "; sensitivity " + sens + "\";\nbind " + button + " \"alias zoomin " + label + "; echo \'bound " + name + "\'\";")
    }
}

//---------------------------------------------------------------------------------------------------------------------------
//    Target Spawn Delays
//---------------------------------------------------------------------------------------------------------------------------
targetSpawnDelaySelector <- RadioButton(["target_delay_0", "target_delay_1", "target_delay_2", "target_delay_3", "target_delay_4"])

function setTargetDelay(delay){
    EntFire("target_timer", "RefireTime", delay)
    if(delay == 0.42){
        targetSpawnDelaySelector.select(0)
    }
    else if(delay == 0.39){
        targetSpawnDelaySelector.select(1)
    }
    else if(delay == 0.36){
        targetSpawnDelaySelector.select(2)
    }
    else if(delay == 0.33){
        targetSpawnDelaySelector.select(3)
    }
    else if(delay == 0.30){
        targetSpawnDelaySelector.select(4)
    }
}

//---------------------------------------------------------------------------------------------------------------------------
// Debug
//---------------------------------------------------------------------------------------------------------------------------
function debug(){
    EntFire("start_sound", "PlaySound", "")
    printl("debug fired")
	EntFire("maker_logic_script", "RunScriptCode", "makeTargetAtLocation(0, -76.5)")
}
