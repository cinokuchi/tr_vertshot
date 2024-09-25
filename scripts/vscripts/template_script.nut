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
        {
            printl("targetname " + targetname + " does NOT equal target_logic_script")
			EntFireByHandle(logic_script_handle, "RunScriptCode", "registerPieces()", 0, handle, self)
        }
        else
        {
            printl("targetname " + targetname + " DOES equal target_logic_script")
        }
	}
    
    EntFire("maker_logic_script", "RunScriptCode", "addTarget(\"" + logic_script_handle + "\")")
}