--README Leggi la spiegazione su come usare i miei trigger cosi da non fare cazzate, :)



--[[ 

    Using Table  = AllTableKD

        la tabella "AllTableKD" contiene tutti i dati del kd sincronizzati dal server utilizzando il trigger "fnx-kd_system:SyncKd", la tabella viene sincronizzata quando il player spawna ed ogni volta che il player fa una kill o ogni volta che muore
    
        esempio :
        
        if AllTableKD ~= nil then 
            --la tabella AllTableKD è nil finche il player non è stato caricato quindi questo semplice controllo permette di non rompere il codice seguente

            print("KD: ",AllTableKD.kd, "KILL: ",AllTableKD.kill, "MORTI: ",AllTableKD.morti, "KD REDZONE: ",AllTableKD.redzonekd, " REDZONE KILL: ",AllTableKD.redzonekill, " REDZONE MORTI: ",AllTableKD.redzonemorti)
        end
]]


--[[ 

    Using export  = "getClientKd" 

    l export "getClientKd" serve ad ottenere a tabella del kd del player puo tornarvi utile per creare un hud o un menu o quello che volete
]]

--[[  -- Contenuto tabella AllTableKD
      AllTableKD = {
          
            AllTableKD.kd =             "totale kd"
            AllTableKD.kill =           "totale kill"
            AllTableKD.morti =          "totale morti"
            AllTableKD.redzonekd =      "totale redzone kd"
            AllTableKD.redzonekill =    "totale redzone kill"
            AllTableKD.redzonemorti =   "totale redzone morti"
      }  

]]


local AllTableKD = nil 


Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if NetworkIsPlayerActive(PlayerId()) then
            Wait(5000)
            TriggerServerEvent("fnx-kd_system:spawnPed")
			break
		end
	end
end)


RegisterNetEvent("fnx-kd_system:SyncKd")
AddEventHandler("fnx-kd_system:SyncKd", function(KD) 
    AllTableKD  = KD 
    TriggerEvent('fnx-t-open', 'kd_active', "<b>Stats</b></p>KD: "..(AllTableKD.kd or 0).."</p>Kill: "..(AllTableKD.kill or 0).."</p>Morti: "..(AllTableKD.morti or 0))
end)

local toogle = true
RegisterCommand("toggle_kd_hud",function ()
    toogle = not toogle
    if type(AllTableKD) == "table" then
        if toogle then
            TriggerEvent('fnx-t-open', 'kd_active', "<b>Stats</b></p>KD: "..(AllTableKD.kd or 0).."</p>Kill: "..(AllTableKD.kill or 0).."</p>Morti: "..(AllTableKD.morti or 0))
        else
            TriggerEvent('fnx-t-close', 'kd_clode')
        end
    end
end)


exports('getClientKd',function()   --return all table AllTableKD
    if AllTableKD ~= nil then
        return AllTableKD
    end
end)
