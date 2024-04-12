function PreSpawnInstance( entityClass, entityName )
{
	return null
}

function PostSpawn( entities )
{
	//registers the just-spawned targetPieces to the target_logic_script
	//so that they may be deleted on hit.
	local logic_script_handle = entities["target_logic_script"]
	EntFire("target_maker_logic_script",
		"RunScriptCode",
		"sendLocation()",
		0, logic_script_handle)
	foreach( targetname, handle in entities )
	{
		if(targetname != "target_logic_script")
			EntFireByHandle(logic_script_handle, "RunScriptCode", "register()", 0, activator, handle)
	}
}