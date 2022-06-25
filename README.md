# wert-notes
Free basic not system

# Change this codes qb-menu
RegisterNUICallback('closeMenu', function()
    headerShown = false
    sendData = nil
    SetNuiFocus(false)
    TriggerEvent("wert-notes:client:qb-menu-close") -- this event add
end)

# Please upload sql file your database ( notes.sql )



Item name : "stickynote"

['stickynote'] 			 	 	 = {['name'] = 'stickynote', 			  		['label'] = 'Sticky note', 				['weight'] = 0, 		['type'] = 'item', 		['image'] = 'stickynote.png', 			['unique'] = true, 		['useable'] = false, 	['shouldClose'] = false,   ['combinable'] = nil,   ['description'] = 'Sometimes handy to remember something :)'},
