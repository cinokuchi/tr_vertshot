IncludeScript("target_0_module.nut")

/*
    Where O is the eye position as a vector,
    D is the eye direction as a vector,
    and tickOffset is the amount of ticks backwards to check the position of the target
*/
function checkHit(Ox, Oy, Oz, Dx, Dy, Dz, tickFracion, lowTick){
    local distSqrd = computeClosestApproach(Ox, Oy, Oz, Dx, Dy, Dz, tickFracion, lowTick)
    if(distSqrd == null){
        return
    }
    else if(distSqrd < 4){
        EntFire("main_logic_script", "RunScriptCode", "getHit(0)", 0, activator)
        EntFire("target_sound_0", "PlaySound")
    }
    else if(distSqrd < 16){
        EntFire("main_logic_script", "RunScriptCode", "getHit(1)", 0, activator)
        EntFire("target_sound_1", "PlaySound")
    }
    else if(distSqrd < 36){
        EntFire("main_logic_script", "RunScriptCode", "getHit(2)", 0, activator)
        EntFire("target_sound_2", "PlaySound")
    }
    else if(distSqrd < 64){
        EntFire("main_logic_script", "RunScriptCode", "getHit(3)", 0, activator)
        EntFire("target_sound_3", "PlaySound")
    }
    else if(distSqrd < 144){
        EntFire("target_sound_miss", "PlaySound")
    }
}