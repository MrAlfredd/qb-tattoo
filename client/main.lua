local QBCore = exports['qb-core']:GetCoreObject()

local currentTattoos = {}
local cam = nil
local back = 1
local opacity = 1
local defaultOutfit = {}
local isMenuOpen = false

local lastSelectedTattoo = {
    hash = "",
    collection = "",
    price = 0,
    name = "",
}



local function DrawTattoo(collection, name)
    ClearPedDecorations(PlayerPedId())
    for k, v in pairs(currentTattoos) do
        if v.Count ~= nil then
            for i = 1, v.Count do
                AddPedDecorationFromHashes(PlayerPedId(), v.collection, v.nameHash)
            end
        else
            AddPedDecorationFromHashes(PlayerPedId(), v.collection, v.nameHash)
        end
    end
    for i = 1, opacity do
        AddPedDecorationFromHashes(PlayerPedId(), collection, name)
    end
end

local function setTattoos()
    ClearPedDecorations(PlayerPedId())
    for k, v in pairs(currentTattoos) do
        if v.Count ~= nil then
            for i = 1, v.Count do
                AddPedDecorationFromHashes(PlayerPedId(), v.collection, v.nameHash)
            end
        else
            AddPedDecorationFromHashes(PlayerPedId(), v.collection, v.nameHash)
        end
    end
end

local function BuyTattoo(collection, name, label, price)
    QBCore.Functions.TriggerCallback('SmallTattoos:PurchaseTattoo', function(success)
        if success then
            currentTattoos[#currentTattoos + 1] = { collection = collection, nameHash = name, Count = opacity }
        end
    end, currentTattoos, price, { collection = collection, nameHash = name, Count = opacity }, GetLabelText(label))
end

local function RemoveTattoo(name, label)
    for k, v in pairs(currentTattoos) do
        if v.nameHash == name then
            table.remove(currentTattoos, k)
        end
    end
    TriggerServerEvent("SmallTattoos:RemoveTattoo", currentTattoos)
    QBCore.Functions.Notify("You have removed the " .. GetLabelText(label) .. " tattoo")
    setTattoos()
end


local nakedPed = {
    male = {
        outfitData = {
            ['t-shirt'] = { item = 15, texture = 0 },
            ['torso2'] = { item = 15, texture = 0 },
            ['arms'] = { item = 15, texture = 0 },
            ['pants'] = { item = 14, texture = 0 },
            ['vest'] = { item = 0, texture = 0 },
            ['bag'] = { item = 0, texture = 0 },
        }
    },
    female = {
        outfitData = {
            ['t-shirt'] = { item = 14, texture = 0 },
            ['torso2'] = { item = 15, texture = 0 },
            ['arms'] = { item = 15, texture = 0 },
            ['pants'] = { item = 15, texture = 0 },
            ['shoes'] = { item = 0, texture = 0 },
            ['vest'] = { item = 0, texture = 0 },
            ['bag'] = { item = 0, texture = 0 },
        }
    }
}



function GetNaked()
    local playerData = QBCore.Functions.GetPlayerData()
    QBCore.Functions.TriggerCallback('qb-multicharacter:server:getSkin', function(model, data)
        defaultOutfit = json.decode(data)
        --debugPrint(defaultOutfit)
        if model == "1885233650" then
            TriggerEvent('qb-clothing:client:loadOutfit', nakedPed.male)
        elseif model == '-1667301416' then
            TriggerEvent('qb-clothing:client:loadOutfit', nakedPed.female)
        end
    end, playerData.citizenid)
end

-- Call this function when exiting to reset clothes.
local function resetClothes()
    TriggerEvent('qb-clothing:client:loadPlayerClothing', defaultOutfit)

    setTattoos()
end

function CloseMenu()
    print("CLOSEFUNCTION")
    back = 1
    opacity = 1
    --ResetSkin()
    lastSelectedTattoo = {
        hash = "",
        collection = "",
        price = 0,
        name = "",
    }

    FreezeEntityPosition(PlayerPedId(), false)

    if DoesCamExist(cam) then
        DetachCam(cam)
        SetCamActive(cam, false)
        RenderScriptCams(false, false, 0, 1, 0)
        DestroyCam(cam, false)
    end
    TriggerEvent("qb-menu:closeMenu")
    resetClothes()
    isMenuOpen = false
end


RegisterCommand('loadt', function(source)
    QBCore.Functions.TriggerCallback('SmallTattoos:GetPlayerTattoos', function(tattooList)
        if tattooList then
            ClearPedDecorations(PlayerPedId())
            for k, v in pairs(tattooList) do
                if v.Count ~= nil then
                    for i = 1, v.Count do
                        AddPedDecorationFromHashes(PlayerPedId(), v.collection, v.nameHash)
                    end
                else
                    AddPedDecorationFromHashes(PlayerPedId(), v.collection, v.nameHash)
                end
            end
            currentTattoos = tattooList
        end
    end)
end)

local function RemoveMenu()
    local list = {}
    list[#list + 1] = {
        isMenuHeader = true,
        header = "Tattoos",
        txt = "",
    }
    list[#list + 1] = {
        header = "< Back",
        txt = "",
        params = {
            isAction = true,
            event = function()
                TattooMenu()
            end,
        },
    }

    for k, v in pairs(currentTattoos) do
        for _, tattoo in pairs(Config.AllTattooList) do
            if v.nameHash == tattoo.HashNameMale or v.nameHash == tattoo.HashNameFemale then
                list[#list + 1] = {
                    header = GetLabelText(tattoo.Name),
                    params = {
                        isAction = true,
                        event = function()
                            RemoveTattoo(v.nameHash, tattoo.Name)
                            RemoveMenu()
                        end,
                    },
                }
            end
        end
    end

    exports['qb-menu']:openMenu(list)
end

function TattooMenu()
    
    GetNaked()
    isMenuOpen = true
    FreezeEntityPosition(PlayerPedId(), true)
    if DoesCamExist(cam) then
        DetachCam(cam)
        SetCamActive(cam, false)
        RenderScriptCams(false, false, 0, 1, 0)
        DestroyCam(cam, false)
    end

    local list = {}
    list[#list + 1] = {
        isMenuHeader = true,
        header = "Tattoos",
        txt = "",
    }
    list[#list + 1] = {
        header = "< Close",
        txt = "",
        params = {
            isAction = true,
            event = function()
                CloseMenu()
            end,
        },
    }

    list[#list + 1] = {
        header = "Remove tattoos",
        txt = "You have " .. #currentTattoos .. " tattoos you can remove.",
        params = {
            isAction = true,
            event = function()
                RemoveMenu()
            end,
        },
    }

    for k, tattooZone in ipairs(Config.TattooCats) do
        local count = 0
        for _, tattoo in pairs(Config.AllTattooList) do
            if tattoo.Zone == tattooZone[1] then
                if GetEntityModel(PlayerPedId()) == `mp_m_freemode_01` then
                    if tattoo.HashNameMale ~= '' then
                        count = count + 1
                    end
                elseif GetEntityModel(PlayerPedId()) == `mp_f_freemode_01` then
                    if tattoo.HashNameFemale ~= '' then
                        count = count + 1
                    end
                end
            end
        end
        list[#list + 1] = {
            header = tattooZone[2],
            txt = count .. " tattoos",
            params = {
                isAction = true,
                event = function()
                    OpenCategory(tattooZone)
                end,
            },
        }
    end

    exports['qb-menu']:openMenu(list)
end

RegisterCommand('tattoo', function(source)
    TattooMenu()
end)

local function setupCamera(tattooZone)
    if not DoesCamExist(cam) then
        cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 0, true, true)
        StopCamShaking(cam, true)
    end
    if GetCamCoord(cam) ~= GetOffsetFromEntityInWorldCoords(PlayerPedId(), tattooZone[3][back]) then
        SetCamCoord(cam, GetOffsetFromEntityInWorldCoords(PlayerPedId(), tattooZone[3][back]))
        PointCamAtCoord(cam, GetOffsetFromEntityInWorldCoords(PlayerPedId(), tattooZone[4]))
    end
end

function OpenCategory(tattooZone)
    setupCamera(tattooZone)
  
    local price = math.ceil(lastSelectedTattoo.price / Config.Discount)
    local list = {}
    list[#list + 1] = {
        isMenuHeader = true,
        header = tattooZone[2],
        txt = "",
    }
    list[#list + 1] = {
        header = "< Go Back",
        params = {
            isAction = true,
            event = function()
                TattooMenu()
                setTattoos()
            end,
        },
    }
    list[#list + 1] = {
        header = "Change camera",
        txt = "Current: " .. back,
        params = {
            isAction = true,

            event = function()
                
                --back = (back % tattooZone[3]) + 1
                if back == #tattooZone[3] then
                    back = 1
                else
                    back = back + 1
                end
                OpenCategory(tattooZone)
            end,
        },
    }
    list[#list + 1] = {
        header = "Increase opacity",
        txt = 'Current opacity: ' .. opacity,
        params = {
            isAction = true,
            event = function()
                if opacity == 10 then
                    opacity = 10
                else
                    opacity = opacity + 1
                end

                
                OpenCategory(tattooZone)
                DrawTattoo(lastSelectedTattoo.collection, lastSelectedTattoo.hash)
            end,
        },
    }
    list[#list + 1] = {
        header = "Decrease opacity",
        txt = 'Current opacity: ' .. opacity,
        params = {
            isAction = true,
            event = function()
                if opacity == 1 then
                    opacity = 1
                else
                    opacity = opacity - 1
                end

                
                OpenCategory(tattooZone)
                DrawTattoo(lastSelectedTattoo.collection, lastSelectedTattoo.hash)
            end,
        },
    }

    list[#list + 1] = {
        header = "Buy",
        txt = lastSelectedTattoo.hash == "" and "Select a tattoo first" or "Price: " .. price,
        disabled = lastSelectedTattoo.hash == "", -- set to true by default, or false if a tattoo is selected
        params = {
            isAction = true,
            event = function()
                --TattooMenu()
                BuyTattoo(lastSelectedTattoo.collection, lastSelectedTattoo.hash, lastSelectedTattoo.name, price)
                
                TattooMenu()
            end,
        },
    }
    -- find the index of the last selected tattoo in the list
    local startIndex = 1
    for i, tattoo in ipairs(Config.AllTattooList) do
        if tattoo.Zone == tattooZone[1] and (tattoo.HashNameMale == lastSelectedTattoo.hash or tattoo.HashNameFemale == lastSelectedTattoo.hash) then
            startIndex = i
            break
        end
    end

    -- add the tattoos from the last selected one to the end of the list
    for i = startIndex, #Config.AllTattooList do
        local tattoo = Config.AllTattooList[i]
        if tattoo.Zone == tattooZone[1] and ((GetEntityModel(PlayerPedId()) == `mp_m_freemode_01` and tattoo.HashNameMale ~= '') or (GetEntityModel(PlayerPedId()) == `mp_f_freemode_01` and tattoo.HashNameFemale ~= '')) then
            local alreadyHasTattoo = false
            for _, currentTattoo in ipairs(currentTattoos) do
                if currentTattoo.nameHash == tattoo.HashNameMale or currentTattoo.nameHash == tattoo.HashNameFemale then
                    alreadyHasTattoo = true
                    break
                end
            end
            local header = GetLabelText(tattoo.Name)
            local disabled = false

            if alreadyHasTattoo then
                header = header .. " (You already have this)"
                disabled = true
            elseif (lastSelectedTattoo.hash == tattoo.HashNameMale and GetEntityModel(PlayerPedId()) == `mp_m_freemode_01`) or (lastSelectedTattoo.hash == tattoo.HashNameFemale and GetEntityModel(PlayerPedId()) == `mp_f_freemode_01`) then
                header = header .. " (Last selected)"
                disabled = true
            end

            list[#list + 1] = {
                header = header,
                txt = "Price: " .. math.ceil(tattoo.Price / Config.Discount),
                disabled = disabled,
                params = {
                    isAction = true,
                    event = function()
                        if GetEntityModel(PlayerPedId()) == `mp_m_freemode_01` then
                            lastSelectedTattoo = {
                                name = tattoo.Name,
                                hash = tattoo.HashNameMale,
                                collection = tattoo.Collection,
                                price = tattoo.Price
                            }
                        elseif GetEntityModel(PlayerPedId()) == `mp_f_freemode_01` then
                            lastSelectedTattoo = {
                                name = tattoo.Name,
                                hash = tattoo.HashNameFemale,
                                collection = tattoo.Collection,
                                price = tattoo.Price
                            }
                        end
                        OpenCategory(tattooZone)
                        if GetEntityModel(PlayerPedId()) == `mp_m_freemode_01` then
                            DrawTattoo(tattoo.Collection, tattoo.HashNameMale)
                        elseif GetEntityModel(PlayerPedId()) == `mp_f_freemode_01` then
                            DrawTattoo(tattoo.Collection, tattoo.HashNameFemale)
                        end
                    end,
                },
            }
        end
    end
    -- add the tattoos from the beginning of the list up to the last selected one
    for i = 1, startIndex - 1 do
        local tattoo = Config.AllTattooList[i]
        if tattoo.Zone == tattooZone[1] and ((GetEntityModel(PlayerPedId()) == `mp_m_freemode_01` and tattoo.HashNameMale ~= '') or (GetEntityModel(PlayerPedId()) == `mp_f_freemode_01` and tattoo.HashNameFemale ~= '')) then
            local alreadyHasTattoo = false
            for _, currentTattoo in ipairs(currentTattoos) do
                if currentTattoo.nameHash == tattoo.HashNameMale or currentTattoo.nameHash == tattoo.HashNameFemale then
                    alreadyHasTattoo = true
                    break
                end
            end
            local header = GetLabelText(tattoo.Name)
            local disabled = false

            if alreadyHasTattoo then
                header = header .. " (You already have this)"
                disabled = true
            elseif (lastSelectedTattoo.hash == tattoo.HashNameMale and GetEntityModel(PlayerPedId()) == `mp_m_freemode_01`) or (lastSelectedTattoo.hash == tattoo.HashNameFemale and GetEntityModel(PlayerPedId()) == `mp_f_freemode_01`) then
                header = header .. " (Last selected)"
                disabled = true
            end

            list[#list + 1] = {
                header = header,
                txt = "Price: " .. math.ceil(tattoo.Price / Config.Discount),
                disabled = disabled,
                params = {
                    isAction = true,
                    event = function()
                        if GetEntityModel(PlayerPedId()) == `mp_m_freemode_01` then
                            lastSelectedTattoo = {
                                name = tattoo.Name,
                                hash = tattoo.HashNameMale,
                                collection = tattoo.Collection,
                                price = tattoo.Price
                            }
                        elseif GetEntityModel(PlayerPedId()) == `mp_f_freemode_01` then
                            lastSelectedTattoo = {
                                name = tattoo.Name,
                                hash = tattoo.HashNameFemale,
                                collection = tattoo.Collection,
                                price = tattoo.Price
                            }
                        end
                        OpenCategory(tattooZone)
                        if GetEntityModel(PlayerPedId()) == `mp_m_freemode_01` then
                            DrawTattoo(tattoo.Collection, tattoo.HashNameMale)
                        elseif GetEntityModel(PlayerPedId()) == `mp_f_freemode_01` then
                            DrawTattoo(tattoo.Collection, tattoo.HashNameFemale)
                        end
                    end,
                },
            }
        end
    end
    -- setTattoos()
    exports['qb-menu']:openMenu(list)
end


AddEventHandler('qb-menu:client:menuClosed', function()
    if isMenuOpen then
        print("CLOSEEVENT")
        CloseMenu()
    end
end)

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    Wait(5000)
    QBCore.Functions.TriggerCallback('SmallTattoos:GetPlayerTattoos', function(tattooList)
        if tattooList then
            ClearPedDecorations(PlayerPedId())
            for k, v in pairs(tattooList) do
                if v.Count ~= nil then
                    for i = 1, v.Count do
                        AddPedDecorationFromHashes(PlayerPedId(), v.collection, v.nameHash)
                    end
                else
                    AddPedDecorationFromHashes(PlayerPedId(), v.collection, v.nameHash)
                end
            end
            currentTattoos = tattooList
        end
    end)
end)


CreateThread(function()
    while true do
        Wait(300000)
        if not isMenuOpen then
            QBCore.Functions.TriggerCallback('SmallTattoos:GetPlayerTattoos', function(tattooList)
                if tattooList then
                    ClearPedDecorations(PlayerPedId())
                    for k, v in pairs(tattooList) do
                        if v.Count ~= nil then
                            for i = 1, v.Count do
                                AddPedDecorationFromHashes(PlayerPedId(), v.collection, v.nameHash)
                            end
                        else
                            AddPedDecorationFromHashes(PlayerPedId(), v.collection, v.nameHash)
                        end
                    end
                    currentTattoos = tattooList
                end
            end)
        end
    end
end)

local TattooControlPress = false
local function TattooControl()
    CreateThread(function()
        TattooControlPress = true
        while TattooControlPress do
            if IsControlPressed(0, 38) then
                exports['qb-core']:KeyPressed()
                TriggerEvent('qb-tattoo:openMenu')
            end
            Wait(0)
        end
    end)
end

RegisterNetEvent("qb-tattoo:openMenu", function()
    TattooMenu()
end)


CreateThread(function()
    if Config.UseTarget then
        for k, v in pairs(Config.Zones) do
            exports["qb-target"]:AddBoxZone("Tattoo_" .. k, v.position, v.length, v.width, {
                name = "Tattoo_" .. k,
                heading = v.heading,
                minZ = v.minZ,
                maxZ = v.maxZ
            }, {
                options = {
                    {
                        type = "client",
                        event = "qb-tattoo:openMenu",
                        icon = "fa-solid fa-paintbrush",
                        label = "Tattoo shop",
                    }
                },
                distance = 1.5
            })
        end
    elseif Config.UseObject then
        exports["qb-target"]:AddTargetModel(Config.TattooObjects, {
            options = {
                {
                    type = "client",
                    event = "qb-tattoo:openMenu",
                    icon = "fa-solid fa-paintbrush",
                    label = "Tattoo shop",

                },
            },
            distance = 6.0
        })
    else
        local tattooPoly = {}
        for k, v in pairs(Config.Shops) do
            tattooPoly[#tattooPoly + 1] = BoxZone:Create(vector3(v.x, v.y, v.z), 1.5, 1.5, {
                heading = -20,
                name = "tattoo" .. k,
                debugPoly = true,
                minZ = v.z - 1,
                maxZ = v.z + 1,
            })
            local tattooCombo = ComboZone:Create(tattooPoly, { name = "tattooPoly" })
            tattooCombo:onPlayerInOut(function(isPointInside)
                if isPointInside then
                    exports['qb-core']:DrawText("Press [E] to open tattoo menu", 'left')
                    TattooControl()
                else
                    TattooControlPress = false
                    exports['qb-core']:HideText()
                end
            end)
        end
    end
end)

CreateThread(function()
    AddTextEntry("ParaTattoos", "Tattoo Shop")
    for k, v in pairs(Config.Shops) do
        local blip = AddBlipForCoord(v)
        SetBlipSprite(blip, 75)
        SetBlipColour(blip, 1)
        SetBlipScale(blip, 0.8)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("ParaTattoos")
        EndTextCommandSetBlipName(blip)
    end
end)
