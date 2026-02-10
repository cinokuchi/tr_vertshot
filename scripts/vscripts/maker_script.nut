IncludeScript("math_module.nut")

//---------------------------------------------------------------------------------------------------------------------------
bigSpawner <- Entities.CreateByClassname("env_entity_maker")
bigSpawner.__KeyValueFromString( "EntityTemplate", "big_targetTemplate")
smallSpawner <- Entities.CreateByClassname("env_entity_maker")
smallSpawner.__KeyValueFromString( "EntityTemplate", "small_targetTemplate")
tinySpawner <- Entities.CreateByClassname("env_entity_maker")
tinySpawner.__KeyValueFromString( "EntityTemplate", "tiny_targetTemplate")

m_hSpawner <- bigSpawner

//Approximate headposition standing on edge of platform.
TARGET_ORIGIN <- Vector(536, 0, 1090)

windowVertOrigin <- 0.0                 //degrees
randomVertOrigin <- 0.0                 //degrees
rho <- 0                                //hammer units (length)
uOffset <- 0.0                          //unitless ratio
vertOffset <- 0.0                       //degrees
vertMin <- 0.0                          //degrees
vertMax <- 0.0                          //degrees

SPAWN_WINDOWED <- 2
SPAWN_RANDOM <- 3
spawnMode <- SPAWN_RANDOM
EPSILON <- 0.001 //for rounding errors

NO_SPEED     <- 0
SLOW_SPEED   <- 1
NORMAL_SPEED <- 2
FAST_SPEED   <- 3
RANDOM_SPEED <- 4
speedMode <- NO_SPEED

//------------------------------------------------------------------------------------------------------------------------
//  Helpers
//------------------------------------------------------------------------------------------------------------------------

//Provides a random u ratio in the legal bounds.
//unitless ratio between side lengths, but sort of in radians because it needs to have
//  an inverse trig function applied to it which will yield radians
function getRandomU(){
	return RandomFloat(-uOffset, uOffset)
}

//Provides a random vert angle in the legal bounds, in degrees.
function getRandomVert(){
    if(spawnMode == SPAWN_WINDOWED){
    	return RandomFloat(max(VERT_MIN, windowVertOrigin - vertOffset), min(VERT_MAX, windowVertOrigin + vertOffset))
    }
    else if(spawnMode == SPAWN_RANDOM){
    	return RandomFloat(max(VERT_MIN, randomVertOrigin - vertOffset), min(VERT_MAX, randomVertOrigin + vertOffset))
    }
}

/*
    returns a vector
    expects horz and vert to be in radians
*/
function vertHorzToCartesian(rho, horz, vert)
{
	local rho_cosHorz = rho * cos(horz)
	return Vector(-rho_cosHorz*cos(vert), rho*sin(horz), rho_cosHorz*sin(vert))
}

//------------------------------------------------------------------------------------------------------------------------
//  Settings
//------------------------------------------------------------------------------------------------------------------------
//make sure WINDOW_INCREMENT divides both VERT_MIN and VERT_MAX evenly
VERT_MIN <- -76.5
VERT_MAX <- 85
WINDOW_INCREMENT <- 8.5

function setFov(sourceFOV){
	rho = getRhoFromSourceFOV(sourceFOV)
	uOffset = getUFromHorz(getHorzOffsetFromSourceFOV(sourceFOV))
	vertOffset = rad2Deg(getVertOffsetFromSourceFOV(sourceFOV))
    //printl(rad2Deg(vertOffset))
	//3 increments per vertOffset
    
    //Clamp windowVertOrigin:
    if(windowVertOrigin >= VERT_MAX - vertOffset - EPSILON){
        windowVertOrigin = ceil((VERT_MAX - vertOffset)/WINDOW_INCREMENT) * WINDOW_INCREMENT
        EntFire("main_logic_script", "RunScriptCode", "moveWindowSilent(" + windowVertOrigin + ")")
    }
    else if (windowVertOrigin <= VERT_MIN + vertOffset + EPSILON){
        windowVertOrigin = floor((VERT_MIN + vertOffset)/WINDOW_INCREMENT) * WINDOW_INCREMENT
        EntFire("main_logic_script", "RunScriptCode", "moveWindowSilent(" + windowVertOrigin + ")")
    }
    
    //Clamp randomVertOrigin:
    if(randomVertOrigin >= VERT_MAX - vertOffset - EPSILON){
        randomVertOrigin = VERT_MAX - vertOffset
        EntFire("main_logic_script", "RunScriptCode", "randomizeWindowSilent(" + randomVertOrigin + ")")
    }
    else if (randomVertOrigin <= VERT_MIN + vertOffset + EPSILON){
        randomVertOrigin = VERT_MIN + vertOffset
        EntFire("main_logic_script", "RunScriptCode", "randomizeWindowSilent(" + randomVertOrigin + ")")
    }
    
    moveFloatingTextHelper("floating_play")
    moveFloatingTextHelper("floating_autoplay")
    moveReflectors()
}

function setSpawnWindowed(){
	spawnMode = SPAWN_WINDOWED
    moveFloatingTextHelper("floating_play")
    moveFloatingTextHelper("floating_autoplay")
}
function setSpawnRandom(){
    spawnMode = SPAWN_RANDOM
    moveFloatingTextHelper("floating_play")
    moveFloatingTextHelper("floating_autoplay")
}

function setBigTargets(){
    m_hSpawner = bigSpawner
}
function setSmallTargets(){
    m_hSpawner = smallSpawner
}
function setTinyTargets(){
    m_hSpawner = tinySpawner
}

function setNoSpeed(){
    speedMode = NO_SPEED
}
function setSlowSpeed(){
    speedMode = SLOW_SPEED
}
function setNormalSpeed(){
    speedMode = NORMAL_SPEED
}
function setFastSpeed(){
    speedMode = FAST_SPEED
}
function setRandomSpeed(){
    speedMode = RANDOM_SPEED
}

function raiseWindow(){
    if(spawnMode == SPAWN_WINDOWED && windowVertOrigin < VERT_MAX - vertOffset - EPSILON){
        windowVertOrigin = windowVertOrigin + WINDOW_INCREMENT
        if(windowVertOrigin > -1 * EPSILON && windowVertOrigin < EPSILON){
            windowVertOrigin = 0.0
        }
        EntFire("main_logic_script", "RunScriptCode", "moveWindowSuccess(" + windowVertOrigin + ")")
        
        //move floating text
        moveFloatingTextHelper("floating_play")
        moveFloatingTextHelper("floating_autoplay")
        moveReflectors()
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
        EntFire("main_logic_script", "RunScriptCode", "moveWindowSuccess(" + windowVertOrigin + ")")
        
        //move floating text
        moveFloatingTextHelper("floating_play")
        moveFloatingTextHelper("floating_autoplay")
        moveReflectors()
    }
    else{
        EntFire("main_logic_script", "RunScriptCode", "moveWindowFailure()")
    }
}
function randomizeWindow(){
    if(spawnMode == SPAWN_RANDOM){
        randomVertOrigin = RandomFloat(VERT_MIN + vertOffset, VERT_MAX - vertOffset)
        EntFire("main_logic_script", "RunScriptCode", "randomizeWindowSuccess(" + randomVertOrigin + ")")
        
        //move floating text
        moveFloatingTextHelper("floating_play")
        moveFloatingTextHelper("floating_autoplay")
    }
    else{
        EntFire("main_logic_script", "RunScriptCode", "randomizeWindowFailure()")
    }
}

//------------------------------------------------------------------------------------------------------------------------
//  Make target
//------------------------------------------------------------------------------------------------------------------------
function makeTarget() {
    myVector <- Vector(getRandomVert(), 0, 0)
	m_hSpawner.SpawnEntityAtLocation(TARGET_ORIGIN, myVector)
}

function setYaw() {
    yaw <- rad2Deg(getHorzFromU(getRandomU()))
    myQAngle <- QAngle(0, yaw, 0)
    caller.SetLocalAngles(myQAngle)
}

function setRoll() {
    myQAngle <- QAngle(0.0, 0.0, RandomFloat(0, 360))
    caller.SetLocalAngles(myQAngle)
}

function setDistance() {
    myVector <- Vector(-rho, 0, 0)
    caller.SetLocalOrigin(myVector)
}

function setRotationSpeed() {
    if(speedMode != NO_SPEED){
        local speed = null
        if(speedMode == SLOW_SPEED){
            speed = 150
        }
        else if(speedMode == NORMAL_SPEED){
            speed = 225
        }
        else if(speedMode == FAST_SPEED){
            speed = 300
        }
        else if(speedMode == RANDOM_SPEED){
            speed = RandomInt(150, 300)
        }
        caller.KeyValueFromFloat("maxspeed", getAngularSpeedFromLinearSpeed(rho, speed))
        caller.AcceptInput("Start", null, null, null)
    }
}

//------------------------------------------------------------------------------------------------------------------------
//  Destroy all targets
//---------------------------------------------------------------------------------------------------------------------------

function removeAllTargets()
{
    //Broadcasts to all targets that they must destroy theirselves
    if(m_hSpawner == bigSpawner){
        EntFire("big_target_pitch*", "KillHierarchy", "")
    }
    else if(m_hSpawner == smallSpawner){
        EntFire("small_target_pitch*", "KillHierarchy", "")
    }
    else if(m_hSpawner == tinySpawner){
        EntFire("tiny_target_pitch*", "KillHierarchy", "")
    }
}

//------------------------------------------------------------------------------------------------------------------------
//  Reflector walls
//------------------------------------------------------------------------------------------------------------------------

/*
    Note - the origins of the reflector_pitch entities are slightly inside from the actual
        center of the brush.
    This is to fix the issue where targets can spawn inside the reflector wall and subsequently
        not get reflected, causing them to bounce around the outside of the spawn area instead of inside.
    By moving the origin slightly inwards, the reflector walls are now slightly outside of the spawn area.
    I didn't calculate everything exactly this time I just moved the origins a bit and said "that looks good".
    Small angle approximation says this should be okay but I didn't test that explicitly.
*/


/*
    Expects angles in radians
*/
function moveReflectorHelper(side, horz, vert){
    local position = vertHorzToCartesian(rho, horz, vert)

	local pitch = rad2Deg(asin(position.z/rho))
	local yaw = -rad2Deg(asin(position.y/rho))
    
    position = position + TARGET_ORIGIN
    
    //pitch and position
    local moveArg = position.x + "," + position.y + "," + position.z + "," + pitch
    EntFire("reflector_pitch_" + side, "RunScriptCode", "move(" + moveArg + ")")
    
    //yaw
    if(yaw != 0){
        EntFire("reflector_yaw_" + side, "RunScriptCode", "yaw(" + yaw + ")")
    }
    //printl(position + ";" + pitch + ";" + yaw)
}

function moveReflectors(){
    local vertOrigin = null
    if(spawnMode == SPAWN_WINDOWED){
        vertOrigin = windowVertOrigin
    }
    else if(spawnMode == SPAWN_RANDOM){
        vertOrigin = randomVertOrigin
    }
    local horzOffset = getHorzFromU(uOffset)
    local vertTop = deg2Rad(vertOrigin + vertOffset)
    local vertBot = deg2Rad(vertOrigin - vertOffset)
    local vertCenter = deg2Rad(vertOrigin)
    moveReflectorHelper("top", 0, vertTop)
    moveReflectorHelper("bottom", 0, vertBot)
    moveReflectorHelper("left", -horzOffset, vertCenter)
    moveReflectorHelper("right", horzOffset, vertCenter)
}

//------------------------------------------------------------------------------------------------------------------------
//  Floating Play
//------------------------------------------------------------------------------------------------------------------------
//floatingPlaySpawner <- Entities.CreateByClassname("env_entity_maker")
//floatingPlaySpawner.__KeyValueFromString( "EntityTemplate", "floating_play_template")

function moveFloatingTextHelper(entityName){
    local position = null
    if(spawnMode == SPAWN_WINDOWED){
        position = vertHorzToCartesian(rho, 0.0, deg2Rad(windowVertOrigin))
    }
    else if(spawnMode == SPAWN_RANDOM){
        position = vertHorzToCartesian(rho, 0.0, deg2Rad(randomVertOrigin))
    }

	local phi = getSign(position.x) * rad2Deg(acos(position.z/rho))
	local theta = position.x == 0 ? getSign(position.y) * 90 : rad2Deg(atan(position.y/position.x))
	local direction = Vector(
        phi,
        theta,
        0
    )
    position = position + TARGET_ORIGIN
    local moveArg = position.x + "," + position.z + "," + phi + "," + theta
    EntFire(entityName, "RunScriptCode", "move(" + moveArg + ")")
}

function makeFloatingPlay(){
    moveFloatingTextHelper("floating_play")
    EntFire("floating_play", "RunScriptCode", "show()")
}

function deleteFloatingPlay(){
    EntFire("floating_play", "RunScriptCode", "hide()")
}

//------------------------------------------------------------------------------------------------------------------------
//  Autoplay
//------------------------------------------------------------------------------------------------------------------------
//floatingAutoplaySpawner <- Entities.CreateByClassname("env_entity_maker")
//floatingAutoplaySpawner.__KeyValueFromString( "EntityTemplate", "floating_autoplay_template")

autoplayCountdown <- 0

function startAutoplayCountdown(){
    moveFloatingTextHelper("floating_autoplay")
    autoplayCountdown = 3
    EntFire("floating_autoplay_worldtext_2", "AddOutput", "message in 3...")
    EntFire("floating_autoplay", "RunScriptCode", "show()")
    EntFire("autoplay_timer", "Enable", "")
}

function decrementAutoplayCountdown(){
    autoplayCountdown = autoplayCountdown - 1
    EntFire("floating_autoplay_worldtext_2", "AddOutput", "message in " + autoplayCountdown + "...")
    if(autoplayCountdown <= 0){
        EntFire("main_logic_script", "RunScriptCode", "autoplayTimerTimeout()")
    }
}

function stopAutoplayCountdown(){
    EntFire("floating_autoplay", "RunScriptCode", "hide()")
	EntFire("autoplay_timer", "Disable", "")
}


//TODO figure out how to redraw the floating play button when moving the windows.
//I can't just killhierarchy and then redraw it because the entfire goes off after the redraw.

//------------------------------------------------------------------------------------------------------------------------