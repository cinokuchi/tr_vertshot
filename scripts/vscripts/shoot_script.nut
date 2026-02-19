//Table of callbacks to attach to the game
::MyEventTable1 <- {
    //Callback that triggers when a player spawns
	function OnGameEvent_player_spawn(params) 
	{
		local player = GetPlayerFromUserID(params.userid)
        
        //Create a script scope for the player
        player.ValidateScriptScope()
        
        //Declare and initialize a variable within that scope
        player.GetScriptScope().last_fire_time <- 0.0
        
        //Store a handle to the playerManager in the script scope
        player.GetScriptScope().playerManager <- Entities.FindByClassname(null, "tf_player_manager")
        
        //Store a handle to the listen host in the script scope
        player.GetScriptScope().listenHost <- GetListenServerHost()
        
        //Seconds between ticks
        player.GetScriptScope().TICKDELAY <- 0.015
        
        //Declare and initialize the think function within that scope
        player.GetScriptScope().OnPlayerAttack <- function(){
            //self is a handle to a player object
            local weapon = self.GetActiveWeapon()
            
            if (weapon && !weapon.IsMeleeWeapon()) {
                local fire_time = NetProps.GetPropFloat(weapon, "m_flLastFireTime")
                local scope = self.GetScriptScope()
                if (fire_time > scope.last_fire_time) {
                    
                    //Do something interesting
                    local eye_position = self.EyePosition()
                    local eye_fwd = self.EyeAngles().Forward()
                    
                    //DebugDrawLine(eye_position, eye_position + eye_fwd * 2048.0, 255, 0, 0, false, 3.0)
                    
                    //Global latency in seconds
                    local latency = NetProps.GetPropIntArray(scope.playerManager, "m_iPing", self.entindex()) * 0.001
                    //Player latency in seconds
                    if(self != scope.listenHost){
                        latency += NetProps.GetPropFloat(self, "m_fLerpTime")
                        printl("is not listen host")
                    }
                    //Combined latency in ticks:
                    local ticks = (0.5 + latency / TICKDELAY).tointeger()
                    
                    //Can't send vectors so we have to break them down into components and send those:
                    local argument = "checkHit(" +
                        eye_position.x + "," +
                        eye_position.y + "," +
                        eye_position.z + "," +
                        eye_fwd.x + "," +
                        eye_fwd.y + "," +
                        eye_fwd.z + "," +
                        ticks +
                    ")"
                    
                    //Run on all targets
                    EntFire("target_0_*", "RunScriptCode", argument)
                    
                    scope.last_fire_time = fire_time
                }
            }
        }
        
        //Register function to trigger on every server tick
		AddThinkToEnt(player, "OnPlayerAttack")
	}
}

//Attaches callback table to the game
__CollectGameEventCallbacks(MyEventTable1)