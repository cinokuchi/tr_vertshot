//I can't send Vectors because EntFire converts all its arguments to strings before sending
//Hence I'm sending the components of the vectors instead of the vectors theirselves.
function move(x,y,z,pitch)
{
	local position = Vector(
        x,
        y,
        z
    )
    local direction = QAngle(
        pitch,
        0,
        0
    )
    self.SetLocalOrigin(position)
    self.SetLocalAngles(direction)
}