function OnPostSpawn(){
    self.GetRootMoveParent().AcceptInput("RunScriptCode", "registerRotator()", null, self)
    EntFire("maker_logic_script", "RunScriptCode", "setRotationSpeed()")
}