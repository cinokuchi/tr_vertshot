IncludeScript("math_module.nut")

//---------------------------------------------------------------------------------------------------------------------------
bigSpawner <- Entities.CreateByClassname("env_entity_maker")
bigSpawner.__KeyValueFromString( "EntityTemplate", "big_targetTemplate")
smallSpawner <- Entities.CreateByClassname("env_entity_maker")
smallSpawner.__KeyValueFromString( "EntityTemplate", "small_targetTemplate")

m_hSpawner <- bigSpawner

//Approximate headposition standing on edge of platform.
TARGET_ORIGIN <- Vector(536, 0, 1090)

nextUOrigin <- 0.0
nextVertOrigin <- 0.0
windowVertOrigin <- 0.0
randomVertOrigin <- 0.0
rho <- 0
uOffset <- 0.0
vertOffset <- 0.0
randomWindowVertOffset <- 0.0
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
SPAWN_WINDOWED <- 2
SPAWN_RANDOM <- 3
spawnMode <- SPAWN_RANDOM
EPSILON <- 0.001 //for rounding errors

//------------------------------------------------------------------------------------------------------------------------
//make sure WINDOW_INCREMENT divides both VERT_MIN and VERT_MAX evenly
VERT_MIN <- deg2Rad(-51)
VERT_MAX <- deg2Rad(85)
WINDOW_INCREMENT <- deg2Rad(8.5)

function setFov(sourceFOV){
	rho = getRhoFromSourceFOV(sourceFOV)
	uOffset = getUFromHorz(getHorzOffsetFromSourceFOV(sourceFOV))
	vertOffset = getVertOffsetFromSourceFOV(sourceFOV)
    //printl(rad2Deg(vertOffset))
	//3 increments per vertOffset
	walkIncrement = vertOffset/3
    
    //Clamp windowVertOrigin:
    if(windowVertOrigin >= VERT_MAX - vertOffset - EPSILON){
        windowVertOrigin = ceil((VERT_MAX - vertOffset)/WINDOW_INCREMENT) * WINDOW_INCREMENT
        EntFire("main_logic_script", "RunScriptCode", "moveWindowSilent(" + rad2Deg(windowVertOrigin) + ")")
    }
    else if (windowVertOrigin <= VERT_MIN + vertOffset + EPSILON){
        windowVertOrigin = floor((VERT_MIN + vertOffset)/WINDOW_INCREMENT) * WINDOW_INCREMENT
        EntFire("main_logic_script", "RunScriptCode", "moveWindowSilent(" + rad2Deg(windowVertOrigin) + ")")
    }
    
    //Clamp randomVertOrigin:
    if(randomVertOrigin >= VERT_MAX - vertOffset - EPSILON){
        randomVertOrigin = VERT_MAX - vertOffset
        EntFire("main_logic_script", "RunScriptCode", "randomizeWindowSilent(" + rad2Deg(randomVertOrigin) + ")")
    }
    else if (randomVertOrigin <= VERT_MIN + vertOffset + EPSILON){
        randomVertOrigin = VERT_MIN + vertOffset
        EntFire("main_logic_script", "RunScriptCode", "randomizeWindowSilent(" + rad2Deg(randomVertOrigin) + ")")
    }
    
	//printl("vertOffset: " + rad2Deg(vertOffset))
	//printl("walkIncrement: " + rad2Deg(walkIncrement))
	uMin = -uOffset
	uMax = uOffset
}

function setSpawnWalking(){
	spawnMode = SPAWN_WALKING
}
function setSpawnNearby(){
	spawnMode = SPAWN_NEARBY
}
function setSpawnWindowed(){
	spawnMode = SPAWN_WINDOWED
}
function setSpawnRandom(){
    spawnMode = SPAWN_RANDOM
}

function setBigTargets(){
    m_hSpawner = bigSpawner
}
function setSmallTargets(){
    m_hSpawner = smallSpawner
}

function walkSpawns(){
	if(walkDirection == UP && nextVertOrigin >= VERT_MAX - walkIncrement - EPSILON){
		nextVertOrigin = VERT_MAX
		walkDirection = DOWN
	}
	if(walkDirection == DOWN && nextVertOrigin <= VERT_MIN + walkIncrement + EPSILON){
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

function raiseWindow(){
    if(spawnMode == SPAWN_WINDOWED && windowVertOrigin < VERT_MAX - vertOffset - EPSILON){
        windowVertOrigin = windowVertOrigin + WINDOW_INCREMENT
        if(windowVertOrigin > -1 * EPSILON && windowVertOrigin < EPSILON){
            windowVertOrigin = 0.0
        }
        EntFire("main_logic_script", "RunScriptCode", "moveWindowSuccess(" + rad2Deg(windowVertOrigin) + ")")
    }
    else{
        EntFire("main_logic_script", "RunScriptCode", "moveWindowFailure()")
    }
}
function lowerWindow(){
    if(spawnMode == SPAWN_WINDOWED && windowVertOrigin > VERT_MIN + vertOffset + EPSILON){
        windowVertOrigin = windowVertOrigin - WINDOW_INCREMENT
        if(windowVertOrigin > -1 * EPSILON && windowVertOrigin < EPSILON){
            windowVertOrigin = 0.0
        }
        EntFire("main_logic_script", "RunScriptCode", "moveWindowSuccess(" + rad2Deg(windowVertOrigin) + ")")
    }
    else{
        EntFire("main_logic_script", "RunScriptCode", "moveWindowFailure()")
    }
}
function randomizeWindow(){
    if(spawnMode == SPAWN_RANDOM){
        randomVertOrigin = RandomFloat(VERT_MIN + vertOffset, VERT_MAX - vertOffset)
        EntFire("main_logic_script", "RunScriptCode", "randomizeWindowSuccess(" + rad2Deg(randomVertOrigin) + ")")
    }
    else{
        EntFire("main_logic_script", "RunScriptCode", "randomizeWindowFailure()")
    }
}

function resetTargets(){
    nextUOrigin = 0.0
    nextVertOrigin = 0.0
	//walkDirection = UP
    removeAllTargets()
}

//Provides a random u ratio in the legal bounds, in radians.
function getRandomU(){
	return RandomFloat(max(uMin, nextUOrigin - uOffset), min(uMax, nextUOrigin + uOffset))
}

//Provides a random vert angle in the legal bounds, in radians.
function getRandomVert(){
    if(spawnMode == SPAWN_WINDOWED){
    	return RandomFloat(max(VERT_MIN, windowVertOrigin - vertOffset), min(VERT_MAX, windowVertOrigin + vertOffset))
    }
    else if(spawnMode == SPAWN_RANDOM){
    	return RandomFloat(max(VERT_MIN, randomVertOrigin - vertOffset), min(VERT_MAX, randomVertOrigin + vertOffset))
    }
    else{
        return RandomFloat(max(VERT_MIN, nextVertOrigin - vertOffset), min(VERT_MAX, nextVertOrigin + vertOffset))
    }
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


//Make target at a specific horz and vert
//for debug purposes
//Takes horz and vert in degrees
function makeTargetAtLocation(horz, vert)
{
	local position = vertHorzToCartesian(rho, deg2Rad(horz), deg2Rad(vert))
    //printl(position+TARGET_ORIGIN)
	//acos only returns positive
	local phi = getSign(position.x) * rad2Deg(acos(position.z/rho))
	local theta = position.x == 0 ? getSign(position.y) * 90 : rad2Deg(atan(position.y/position.x))
	local direction = Vector(
			phi,
			theta,
			0)
	m_hSpawner.SpawnEntityAtLocation(position + TARGET_ORIGIN, direction)
}

function makeTargetAtWindowOrigin(){
    //printl(windowVertOrigin)
    makeTargetAtLocation(0, rad2Deg(randomVertOrigin))
    printl(rad2Deg(vertOffset))
    print(rad2Deg(getHorzFromU(uOffset)))
}

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
    
    //Target was shot at the same time as it was broadcast deleted.
    if(!(logic_script_handle in targetTable)){
        return
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
    if(m_hSpawner == bigSpawner){
        EntFire("big_target_logic_script*", "KillHierarchy", "")
    }
    else if(m_hSpawner == smallSpawner){
        EntFire("small_target_logic_script*", "KillHierarchy", "")
    }
}

//------------------------------------------------------------------------------------------------------------------------

floatingPlaySpawner <- Entities.CreateByClassname("env_entity_maker")
floatingPlaySpawner.__KeyValueFromString( "EntityTemplate", "floating_play_template")

function makeFloatingPlay(){
    local position = null
    if(spawnMode == SPAWN_WINDOWED){
        position = vertHorzToCartesian(rho, 0.0, windowVertOrigin)
    }
    else if(spawnMode == SPAWN_RANDOM){
        position = vertHorzToCartesian(rho, 0.0, randomVertOrigin)
    }
    else{
        position = vertHorzToCartesian(rho, 0.0, 0.0)
    }

	local phi = getSign(position.x) * rad2Deg(acos(position.z/rho))
	local theta = position.x == 0 ? getSign(position.y) * 90 : rad2Deg(atan(position.y/position.x))
	local direction = Vector(
			phi,
			theta,
			0)
	floatingPlaySpawner.SpawnEntityAtLocation(position + TARGET_ORIGIN, direction)
}

//TODO figure out how to redraw the floating play button when moving the windows.
//I can't just killhierarchy and then redraw it because the entfire goes off after the redraw.

//------------------------------------------------------------------------------------------------------------------------