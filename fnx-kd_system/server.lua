--README Leggi la spiegazione su come usare i miei trigger cosi da non fare cazzate, :)

--[[ 

    Using trigger  =  "fnx-kd_system:UpdateKD"  

    Far triggerare il trigger dal vostro sistema di morte  gli argomenti da fornire sono = (type,redzone,player)

     -type = kill/morte (il type indica se kd deve aggiornarsi in positivo in caso di type "kill" o in negativo in caso di type "morte")

     -redzone = boolean  (l argomento redzone indica il tipo di kd che deve aggiornarsi, se il valore è true si aggionera il redzonekd, se è false si aggionerà il kd classico) 

     -player = server id (il valore player indica il server id del player a cui aggiornare il kd )

]]



--[[

    Using trigger  =  "fnx-kd_system:SyncKd"  

    Il trigger serve a sincronizzare il kd tra client e server, l unico argomento è il "(src)" server id, il trigger puo essere utile in caso dobbiate sincronizzare il kd in una determinata situazione, per il resto fa gia tutta la sincronizzazione in automatico
]]



--[[ 
    
    Using export  = "getKd" 
    l export "getKd" serve ad ottenere a tabella del kd di un tereminato player gli argomenti da fornire sono = (src)

    -src = server id (il valore src indica il server id del player a cui gettare la tabella del kd )
]]




local Kd = {}

local GetIdentifier = function (src)
    for k,v in ipairs(GetPlayerIdentifiers(src)) do
        if string.match(v, Config.identifier) then
            if Config.identifier == 'license:' then
                return string.gsub(v, 'license:', '')
            end
            return  v
        end
    end
end




RegisterServerEvent("fnx-kd_system:spawnPed")
AddEventHandler("fnx-kd_system:spawnPed", function()  
    local src = source
    local identifier = tostring(GetIdentifier(src))
    MySQL.Async.fetchAll('SELECT * FROM fnx_kd WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    }, function(result) 
        if result and #result > 0 then
            if result[1].data then
               local table =  json.decode(result[1].data)
               Kd[identifier] = {
                    kd              = (tonumber(table.kd)           or 0),
                    kill            = (tonumber(table.kill)         or 0),
                    morti           = (tonumber(table.morti)        or 0),
                    redzonekd       = (tonumber(table.redzonekd)    or 0),
                    redzonekill     = (tonumber(table.redzonekill)  or 0),
                    redzonemorti    = (tonumber(table.redzonemorti) or 0),
               } 
            end
            TriggerClientEvent("fnx-kd_system:SyncKd",src,Kd[identifier])
        else 
            MySQL.Sync.execute('INSERT INTO fnx_kd (identifier) VALUES (@identifier)', {
                ['@identifier'] = identifier,}
            )
               Kd[identifier] = {
                    kd              = 0,
                    kill            = 0,
                    morti           = 0,
                    redzonekd       = 0,
                    redzonekill     = 0,
                    redzonemorti    = 0,
               } 
            TriggerClientEvent("fnx-kd_system:SyncKd",src,Kd[identifier])
        end
    end)
end)



RegisterServerEvent("fnx-kd_system:UpdateKD")
AddEventHandler("fnx-kd_system:UpdateKD",function (type,redzone,player)
    local src = player
    local identifier = tostring(GetIdentifier(src))
    if Kd[identifier] ~= nil then
        if type == "kill" then
            if redzone then
                Kd[identifier].redzonekill = tonumber(Kd[identifier].redzonekill + 1)  
                if tonumber(Kd[identifier].redzonemorti) > 0  then
                    Kd[identifier].redzonekd = math.floor((tonumber(Kd[identifier].redzonekill/Kd[identifier].redzonemorti) * 10^2) + 0.5) / (10^2)
                else
                    Kd[identifier].redzonekd = math.floor((tonumber(Kd[identifier].redzonekill) * 10^2) + 0.5) / (10^2)
                end
                
            else
                Kd[identifier].kill = tonumber(Kd[identifier].kill + 1)
                if tonumber(Kd[identifier].morti) > 0  then
                    Kd[identifier].kd = math.floor((tonumber(Kd[identifier].kill/Kd[identifier].morti) * 10^2) + 0.5) / (10^2)
                else
                    Kd[identifier].kd = math.floor((tonumber(Kd[identifier].kill) * 10^2) + 0.5) / (10^2)
                end
            end
        elseif type == "morte" then
            if redzone then
                Kd[identifier].redzonemorti = tonumber(Kd[identifier].redzonemorti + 1)  
                Kd[identifier].redzonekd =  math.floor((tonumber(Kd[identifier].redzonekill/Kd[identifier].redzonemorti) * 10^2) + 0.5) / (10^2)     
            else
                Kd[identifier].morti = tonumber(Kd[identifier].morti + 1)
                Kd[identifier].kd = math.floor((tonumber(Kd[identifier].kill / Kd[identifier].morti) * 10^2) + 0.5) / (10^2)
            end
        end
        TriggerClientEvent("fnx-kd_system:SyncKd",src,Kd[identifier])
    end
end)



RegisterServerEvent("fnx-kd_system:SyncKd")
AddEventHandler("fnx-kd_system:SyncKd",function ()
    local src = source
    local identifier = tostring(GetIdentifier(src))
    if Kd[identifier] ~= nil then
        TriggerClientEvent("fnx-kd_system:SyncKd",src,Kd[identifier])
    end
end)



exports('getKd',function(src)
    local identifier = tostring(GetIdentifier(src))
    if Kd[identifier] ~= nil then
        return Kd[identifier] 
    end
end)

--[[
RegisterCommand("test",function (src)
    TriggerEvent("fnx-kd_system:UpdateKD","kill",false,src)
end)

RegisterCommand("test1",function (src)
    TriggerEvent("fnx-kd_system:UpdateKD","morte",false,src)
end)
]]

AddEventHandler('playerDropped', function ()
 local src = source
 local identifier = tostring(GetIdentifier(src))
    if Kd[identifier] ~= nil then
        MySQL.Async.execute("UPDATE fnx_kd SET data = @data  WHERE identifier = @identifier", {
            ["@identifier"]     =   identifier,
            ["@data"]           =   json.encode(Kd[identifier]),
        }, function()
            Kd[identifier] = nil
        end)
    end
end)
  
  
