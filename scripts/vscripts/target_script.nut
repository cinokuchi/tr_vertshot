m_targetPieces <- []
m_uAngle <- 0.0
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
		"setLastTargetLocation(" + m_uAngle + "," + m_vertAngle + ")")
	destroyTarget()
}

function saveLocation(uAngle, vertAngle){
	//printl("saveLocation - uAngle: " + uAngle + ", vertAngle: " + vertAngle)
	m_uAngle = uAngle
	m_vertAngle = vertAngle
}