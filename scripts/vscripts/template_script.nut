//------------------------------------------------------------------------------------------------------------------------
function PreSpawnInstance( entityClass, entityName )
{
	return null
}

function PostSpawn( entities )
{
    printl("PostSpawn called")
    
	//registers the just-spawned targetPieces to the target_maker_script
	//so that they may be deleted on hit.
	local logic_script_handle = entities["target_logic_script"]
	foreach( targetname, handle in entities )
	{
		if(targetname != "target_logic_script")
			EntFireByHandle(logic_script_handle, "RunScriptCode", "register()", 0, activator, handle)
        printl("handle " + handle + " added")
	}
    
    EntFire("maker_logic_script", "RunScriptCode", "addTarget()", 0, logic_script_handle)
}