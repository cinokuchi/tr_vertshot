function getHit(index)
{
    //Inform main script so it can increment score and decrement number of live targets
	EntFire("main_logic_script", "RunScriptCode", "getHit(" + index + ")", 0, activator)
    
    //Inform maker script so it can destroy the target and deallocate the data
	EntFire("maker_logic_script","RunScriptCode", "removeTarget(\"" + self + "\")")
    
    self.Destroy()
}

function OnPostSpawn()
{
    EntFire("maker_logic_script", "RunScriptCode", "addTarget(\"" + self + "\")")
}