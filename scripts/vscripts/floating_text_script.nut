//I can't send Vectors because EntFire converts all its arguments to strings before sending
//Hence I'm sending the components of the vectors instead of the vectors theirselves.
function move(x,z,phi,theta)
{
	local position = Vector(
        x,
        0,
        z
    )
    local direction = QAngle(
        phi,
        theta,
        0
    )
    self.SetAbsOrigin(position)
    self.SetAbsAngles(direction)
}

function hide()
{
    for (local child = self.FirstMoveChild(); child != null; child = child.NextMovePeer())
        EntFireByHandle(child, "SetColor", "255 128 0 0", 0, null, null)
}
function show()
{
    for (local child = self.FirstMoveChild(); child != null; child = child.NextMovePeer())
        EntFireByHandle(child, "SetColor", "255 128 0 255", 0, null, null)
}