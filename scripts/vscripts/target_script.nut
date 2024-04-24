m_targetPieces <- []
m_uRatio <- 0.0
m_vertAngle <- 0.0

function register()
{
	m_targetPieces.append(caller)
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
	EntFire("main_logic_script", "RunScriptCode", "getHit(" + index + ")", -1, activator)
	EntFire("targetTemplate",
		"RunScriptCode",
		"setLastTargetLocation(" + m_uRatio + "," + m_vertAngle + ")")
	destroyTarget()
}

function saveLocation(uRatio, vertAngle){
	//printl("saveLocation - uRatio: " + uRatio + ", vertAngle: " + vertAngle)
	m_uRatio = uRatio
	m_vertAngle = vertAngle
}