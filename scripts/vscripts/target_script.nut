m_targetPieces <- []

function registerPiece()
{
    //printl("appended handle " + activator)
	m_targetPieces.append(activator)
}

function destroyTarget()
{
    //printl("destroyTarget called on handle " + self)
	foreach(handle in m_targetPieces)
	{
        //printl("destroying handle " + handle)
		handle.Destroy()
	}
	self.Destroy()
}

function getHit(index)
{
    //Inform main script so it can increment score and decrement number of live targets
	EntFire("main_logic_script", "RunScriptCode", "getHit(" + index + ")", 0, activator)
    
    //Inform maker script so it can destroy the target and deallocate the data
	EntFire("maker_logic_script","RunScriptCode", "removeTarget(\"" + self + "\")")
    
    destroyTarget()
}