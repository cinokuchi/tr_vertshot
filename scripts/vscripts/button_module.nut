const unselected_color = "133 135 120"
const selected_color = "255 128 0"

class RadioButton {
    numOptions = 0
    wtNameList = null
    btnNameList = null
    selectedIndex = 0

    constructor(labelList, defaultSelection = 0){
        numOptions = labelList.len()
        wtNameList = []
        btnNameList = []
        foreach(label in labelList){
            wtNameList.append(label + "_worldtext")
            btnNameList.append(label + "_button")
        }
        
        //select default option
        selectedIndex = defaultSelection
		EntFire(wtNameList[selectedIndex], "SetColor", selected_color)
    }
    
    function select(index){
		EntFire("start_sound", "PlaySound", "")
		EntFire(wtNameList[selectedIndex], "SetColor", unselected_color)
		EntFire(wtNameList[index], "SetColor", selected_color)
        selectedIndex = index
    }
    
    function getSelected(){
        return selectedIndex
    }
}

class CheckmarkButton {
    wtName = ""
    btnName = ""
    isSelected = false

    constructor(label, defaultSelection = false){
        wtName = label + "_worldtext"
        btnName = label + "_button"
        isSelected = defaultSelection
    }
    
    function select(){
		EntFire("start_sound", "PlaySound", "")
		EntFire(wtName, "SetColor", selected_color)
        isSelected = true
    }
    
    function deselect(){
		EntFire("stop_sound", "PlaySound", "")
		EntFire(wtName, "SetColor", unselected_color)
        isSelected = false
    }
    
    function toggle(){
        if(isSelected){
            deselect()
        }
        else{
            select()
        }
    }
    
    function getSelected(){
        return isSelected
    }
}
