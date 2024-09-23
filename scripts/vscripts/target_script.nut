m_targetPieces <- []
m_ownName <- ""

function registerPieces()
{
	m_targetPieces.append(activator)
}

function registerOwnName(name)
{
    m_ownName = name
}

function destroyTarget()
{
	foreach(handle in m_targetPieces)
	{
		handle.Destroy()
	}
	self.Destroy()
}

function getHit(index)
{
    printl("get hit one")
    //Inform main script so it can increment score and decrement number of live targets
	EntFire("main_logic_script", "RunScriptCode", "getHit(" + index + ")", -1, activator)
    
    printl("get hit two")
    //Inform maker script so it can destroy the target and deallocate the data
	EntFire("maker_logic_script","RunScriptCode", "removeTarget(" + m_ownName + ")")
    
    //Destroy self
    destroyTarget()
}