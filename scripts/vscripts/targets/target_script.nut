rotatorHandle <- null

function getHit(index)
{
    //Inform main script so it can increment score and decrement number of live targets
	EntFire("main_logic_script", "RunScriptCode", "getHit(" + index + ")", 0, activator)
    
    self.Destroy()
}

function registerRotator(){
    rotatorHandle = caller
}

function reverseRotator(){
    rotatorHandle.AcceptInput("Reverse", null, null, null)
}