local QBCore = exports['qb-core']:GetCoreObject()

local currentTattoos = {}
local cam = nil
local back = 1
local opacity = 1
local defaultOutfit = {}
local isMenuOpen = false
local currentCamIndex = 1
local currentCamPos, currentHeading, currentOffset = 0, 0, 0
local lastSelectedTattoo = { hash = "", collection = "", price = 0, name = "" }

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

local function SetTattoos()
    lastSelectedTattoo = { hash = "", collection = "", price = 0, name = "" }
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
    SetTattoos()
end

local function GetPositionByRelativeHeading(ped, head, dist)
    local pedPos = GetEntityCoords(ped)

    local finPosx = pedPos.x + math.cos(head * (math.pi / 180)) * dist
    local finPosy = pedPos.y + math.sin(head * (math.pi / 180)) * dist

    return finPosx, finPosy
end


local function IsTattooOwned(name)
    for i, tattoo in ipairs(currentTattoos) do
        if tattoo.nameHash == name then
            return true
        end
    end
    return false
end

local function GetNaked()
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
    SetTattoos()
end




local function SetupCamera(zones)

    if not zones then
        -- Detach camera if no zones provided
        if DoesCamExist(cam) then
            DetachCam(cam)
            SetCamActive(cam, false)
            RenderScriptCams(false, false, 0, 1, 0)
            DestroyCam(cam, false)
        end
        currentCamIndex = 1
        return
    end
    -- If zone is provided then setup camera
    local zoneID = zones.id
    local camPos = Config.Zones[zoneID].camPos[currentCamIndex]
    local lookAt = Config.Zones[zoneID].lookAt
    if not DoesCamExist(cam) then
        cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 0, true, true)
        StopCamShaking(cam, true)
    end
    -- Set camera position and look at target
    local playerPos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), camPos)
    SetCamCoord(cam, playerPos)
    PointCamAtCoord(cam, GetOffsetFromEntityInWorldCoords(PlayerPedId(), lookAt))
    -- Adjust camera position
    local currentHeading = GetEntityHeading(cam) + 180
    local currentOffset = QBCore.Shared.Round(camPos.y, 2)
    local cx, cy = GetPositionByRelativeHeading(PlayerPedId(), currentHeading, currentOffset)
    SetCamCoord(cam, cx, cy, playerPos.z)

    currentCamIndex = 1
    return playerPos, currentHeading, currentOffset
end


local function ChangeCameraZoom(zones, currentCamPos, currentHeading, currentOffset)
    -- Min and Max "zoom" 
    local maxOffset = 2.5
    local minOffset = 0.1
    local currentOffset = math.max(minOffset, math.min(maxOffset, QBCore.Shared.Round(IsDisabledControlPressed(0, 19) and (currentOffset + 0.1) or (currentOffset - 0.1), 2)))
    local cx, cy = GetPositionByRelativeHeading(PlayerPedId(), currentHeading, currentOffset)
    SetCamCoord(cam, cx, cy, currentCamPos.z)
    return GetCamCoord(cam), currentHeading, currentOffset
end



local function ChangeCameraPosition(zones, currentCamPos, currentHeading, currentOffset)
    local zoneID = zones.id
    local lookAt = Config.Zones[zoneID].lookAt
    local ped = PlayerPedId()
    local heading = 0

    -- Exprimental might not work as it suppose to. 
    if IsDisabledControlPressed(0, 36) then
        if IsDisabledControlPressed(0, 19) then
            heading = currentHeading - 90
        else
            heading = currentHeading + 90
        end
    else
        if IsDisabledControlPressed(0, 19) then
            heading = currentHeading - 25
        else
            heading = currentHeading + 25
        end
    end
    local cx, cy = GetPositionByRelativeHeading(ped, heading, currentOffset)
    SetCamRot(cam, -0.0, 0.0, heading, 2)
    SetCamCoord(cam, cx, cy, currentCamPos.z)
    PointCamAtCoord(cam, GetOffsetFromEntityInWorldCoords(PlayerPedId(), lookAt))

    return GetCamCoord(cam), heading, currentOffset
end

local function CloseMenu()
    opacity = 1
    lastSelectedTattoo = { hash = "", collection = "", price = 0, name = "" }
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

local function ShowCurrentTattoos()
    local list = {}
    list[#list + 1] = {
        isMenuHeader = true,
        header = "Current Tattoos",
        txt = "",
    }
    list[#list + 1] = {
        header = "< Go Back",
        txt = "",
        params = {
            isAction = true,
            event = function()
                TattooMenu()
            end,
        },
    }
    for i, tattoo in ipairs(currentTattoos) do
        local tattooName = ""
        local tattooValue = 0
        local tattooZone = ""
        for zoneName, zoneData in pairs(Config.TattooList) do
            for collectionName, collectionData in pairs(zoneData) do
                for _, t in ipairs(collectionData) do
                    if t.hashMale == tattoo.nameHash or t.hashFemale == tattoo.nameHash then
                        local tattooPrice = t.price or 10000
                        tattooName = GetLabelText(t.name)
                        tattooValue = math.ceil(tattooPrice / Config.Discount)
                        tattooZone = t.zone
                        break
                    end
                end
                if tattooName ~= "" then
                    break
                end
            end
            if tattooName ~= "" then
                break
            end
        end

        list[#list + 1] = {
            header = tattooName,
            txt = "Zone: " .. Config.Labels.Zones[tattooZone] .. ", Value: " .. tattooValue .. ", Collection: " .. Config.Labels.Collections[string.lower(tattoo.collection)],
            params = {
                isAction = true,
                event = function()
                    local confirmationMenu = {}
                    confirmationMenu[#confirmationMenu + 1] = {
                        header = "Confirm Removal",
                        isMenuHeader = true,
                    }
                    confirmationMenu[#confirmationMenu + 1] = {
                        header = "Yes",
                        txt = "Are you sure you want to remove this tattoo?",
                        params = {
                            isAction = true,
                            event = function()
                                RemoveTattoo(tattoo.nameHash, tattoo.name)
                                ShowCurrentTattoos()
                            end,
                        },
                    }
                    confirmationMenu[#confirmationMenu + 1] = {
                        header = "Cancel",
                        params = {
                            isAction = true,
                            event = function()
                                ShowCurrentTattoos()
                            end,
                        },
                    }
                    exports['qb-menu']:openMenu(confirmationMenu)
                end,
            },
        }
    end

    exports['qb-menu']:openMenu(list)
end

function OpenCollection(tattoos, zones, collection)
    local collectionList = {}
    collectionList[#collectionList + 1] = {
        isMenuHeader = true,
        header = "Collection: " .. Config.Labels.Collections[string.lower(collection)] .. " Zone: " .. Config.Labels.Zones[zones.zone],
        txt = "",
    }
    collectionList[#collectionList + 1] = {
        header = "< Go Back",
        txt = "Collection selection",
        params = {
            isAction = true,
            event = function()
                SetTattoos()
                OpenZone(zones)
            end,
        },
    }
    collectionList[#collectionList + 1] = {
        header = "Zoom",
        txt = "Current zoom: " .. currentOffset .. ' Hold LALT to decrease.',
        params = {
            isAction = true,
            event = function()
                currentCamPos, currentHeading, currentOffset = ChangeCameraZoom(zones, currentCamPos, currentHeading,
                    currentOffset)
                OpenZone(zones)
            end,
        },
    }
    collectionList[#collectionList + 1] = {
        header = "Change camera",
        txt = "Current rotation: " .. currentHeading .. ' Hold LALT to decrease.',
        params = {
            isAction = true,
            event = function()
                currentCamPos, currentHeading, currentOffset = ChangeCameraPosition(zones, currentCamPos, currentHeading, currentOffset)
                OpenCollection(tattoos, zones, collection)
            end,
        },
    }
    collectionList[#collectionList + 1] = {
        header = "Change opacity",
        txt = 'Current opacity: ' .. opacity .. ' Hold LALT to decrease.',
        params = {
            isAction = true,
            event = function()
                opacity = IsDisabledControlPressed(0, 19) and (opacity == 1 and 1 or opacity - 1) or
                    (opacity == 10 and 10 or opacity + 1)
                DrawTattoo(lastSelectedTattoo.collection, lastSelectedTattoo.hash)
                OpenCollection(tattoos, zones, collection)
            end,
        },
    }
    collectionList[#collectionList + 1] = {
        header = "Buy",
        txt = lastSelectedTattoo.hash == "" and "Select a tattoo first" or "Price: $" .. lastSelectedTattoo.price,
        disabled = lastSelectedTattoo.hash == "",
        params = {
            isAction = true,
            event = function()
                if lastSelectedTattoo.hash ~= "" then
                    local confirmationMenu = {}
                    confirmationMenu[#confirmationMenu + 1] = {
                        header = "Confirmation",
                        isMenuHeader = true,
                    }
                    confirmationMenu[#confirmationMenu + 1] = {
                        header = "Yes",
                        txt = "Are you sure you want to buy this tattoo for $" .. lastSelectedTattoo.price .. " ?",
                        params = {
                            isAction = true,
                            event = function()
                                BuyTattoo(lastSelectedTattoo.collection, lastSelectedTattoo.hash, lastSelectedTattoo.name, lastSelectedTattoo.price)
                                TattooMenu()
                            end,
                        },
                    }
                    confirmationMenu[#confirmationMenu + 1] = {
                        header = "Cancel",
                        params = {
                            isAction = true,
                            event = function()
                                OpenCollection(tattoos, zones, collection)
                            end,
                        },
                    }
                    exports['qb-menu']:openMenu(confirmationMenu)
                end
            end,
        },
    }
    -- Loop through the tattoos in the collection
    for i, tattoo in ipairs(tattoos) do
        local header = tattoo.label
        local isDisabled = false
        local tattooPrice = tattoo.price or 10000
        local price = math.ceil(tattooPrice / Config.Discount)
        if lastSelectedTattoo.name == tattoo.name or lastSelectedTattoo.name == tattoo.name then
            header = tattoo.label .. " ( Current )"
            isDisabled = true
        elseif IsTattooOwned(tattoo.hashMale) or IsTattooOwned(tattoo.hashFemale) then
            header = tattoo.label .. " ( Already has this )"
            isDisabled = true
        end
        if GetEntityModel(PlayerPedId()) == `mp_m_freemode_01` and tattoo.hashMale ~= '' then
            collectionList[#collectionList + 1] = {
                header = header,
                txt = "Price : $" .. price .. " ",
                disabled = isDisabled,
                params = {
                    isAction = true,
                    event = function()
                        lastSelectedTattoo = {
                            name = tattoo.name,
                            hash = tattoo.hashMale,
                            collection = tattoo.collection,
                            price = price
                        }
                        DrawTattoo(tattoo.collection, tattoo.hashMale)
                        OpenCollection(tattoos, zones, collection)
                    end,
                },
            }
        elseif GetEntityModel(PlayerPedId()) == `mp_f_freemode_01` and tattoo.hashFemale ~= '' then
            collectionList[#collectionList + 1] = {
                header = header,
                params = {
                    isAction = true,
                    txt = "Price : $" .. price,
                    event = function()
                        lastSelectedTattoo = {
                            name = tattoo.name,
                            hash = tattoo.hashFemale,
                            collection = tattoo.collection,
                            price = price
                        }
                        DrawTattoo(tattoo.collection, tattoo.hashFemale)
                        OpenCollection(tattoos, zones, collection)
                    end,
                },
            }
        end
    end
    exports['qb-menu']:openMenu(collectionList)
end

function OpenZone(zones)
    local zoneList = {}
    zoneList[#zoneList + 1] = {
        isMenuHeader = true,
        header = "Zone: " .. Config.Labels.Zones[zones.zone] .. "",
        txt = "",
    }
    zoneList[#zoneList + 1] = {
        header = "< Go Back",
        txt = "Zone selection",
        params = {
            isAction = true,
            event = function()
                TattooMenu()
            end,
        },
    }
    zoneList[#zoneList + 1] = {
        header = "Zoom",
        txt = "Current zoom: " .. currentOffset .. ' Hold LALT to decrease.',
        params = {
            isAction = true,
            event = function()
                currentCamPos, currentHeading, currentOffset = ChangeCameraZoom(zones, currentCamPos, currentHeading, currentOffset)
                OpenZone(zones)
            end,
        },
    }
    zoneList[#zoneList + 1] = {
        header = "Change camera",
        txt = "Current rotation: " .. currentHeading .. ' Hold LALT to decrease.',
        params = {
            isAction = true,
            event = function()
                currentCamPos, currentHeading, currentOffset = ChangeCameraPosition(zones, currentCamPos, currentHeading, currentOffset)
                OpenZone(zones)
            end,
        },
    }
    -- Sort the categories alphabetically
    local sortedCollections = {}
    for collection, tattoos in pairs(Config.TattooList[zones.zone]) do
        table.insert(sortedCollections, collection)
    end
    table.sort(sortedCollections)

    for _, collection in ipairs(sortedCollections) do
        local tattoos = Config.TattooList[zones.zone][collection]
        local count = 0

        local ownedTattos = ""
        -- Count the number of tattoos for the collection based on the player gender and the existence of the male or female hash
        for i, tattoo in ipairs(tattoos) do
            if GetEntityModel(PlayerPedId()) == `mp_m_freemode_01` and tattoo.hashMale ~= "" then
                count = count + 1
            elseif GetEntityModel(PlayerPedId()) == `mp_f_freemode_01` and tattoo.hashFemale ~= "" then
                count = count + 1
            end
            local ownedCount = 0
            for i, currentTattoo in ipairs(currentTattoos) do
                if currentTattoo.nameHash == tattoo.hashMale or currentTattoo.nameHash == tattoo.hashFemale then
                    ownedCount = ownedCount + 1
                end
            end
            if ownedCount ~= 0 then
                ownedTattos = "You have " .. ownedCount .. " tattoos of this collection"
            end
        end
        zoneList[#zoneList + 1] = {
            header = Config.Labels.Collections[string.lower(collection)],
            txt = count .. " tattoos available." .. ownedTattos,
            params = {
                isAction = true,
                event = function()
                    OpenCollection(tattoos, zones, collection) -- Open the selected tattoo collecton
                end,
            },
        }
    end

    exports['qb-menu']:openMenu(zoneList)
end

function TattooMenu()
    local list = {}
    list[#list + 1] = {
        isMenuHeader = true,
        header = "Tattoos",
        txt = "",
    }
    list[#list + 1] = {
        header = "< Close",
        txt = "Exit the tattooshop",
        params = {
            isAction = true,
            event = function()
                CloseMenu() -- Closing menu NO SHIT
            end,
        },
    }

    list[#list + 1] = {
        header = "Current tattoos",
        txt = #currentTattoos > 0 and "You have " .. #currentTattoos .. " tattoos." or "You have no tattoos",
        disabled = #currentTattoos == 0 or false,
        params = {
            isAction = true,
            event = function()
                ShowCurrentTattoos() -- Showing current tattoos
            end,
        },
    }

    for i, zones in ipairs(Config.Zones) do
        zones.id = i
        list[#list + 1] = {
            header = Config.Labels.Zones[zones.zone], 
            txt = "Collections for your " .. string.lower(Config.Labels.Zones[zones.zone]),
            params = {
                isAction = true,
                event = function()
                    currentCamPos, currentHeading, currentOffset = SetupCamera(zones)  -- Setting up camera 
                    OpenZone(zones) -- Open the selected zone
                end,
            },
        }
    end
    SetupCamera()
    GetNaked()
    isMenuOpen = true
    FreezeEntityPosition(PlayerPedId(), false)
    exports['qb-menu']:openMenu(list)
end

-- Events 
RegisterNetEvent("qb-tattoo:openMenu", function()
    TattooMenu()
end)

--- This is needed to prevent players from pressing ESC to close the menu and keep the tattoos.
AddEventHandler('qb-menu:client:menuClosed', function()
    if isMenuOpen then
        CloseMenu()
    end
end)

if Config.Multicharacter then
    local loadedTattoos = {}
    RegisterNetEvent('qb-tattoos:loadTattos', function(tattoos)
        loadedTattoos = {}
        if tattoos then
            loadedTattoos = tattoos
        end
    end)
    AddEventHandler('qb-clothing:client:loadPlayerClothing', function(data, ped)
        if loadedTattoos then
            ClearPedDecorations(ped)
            for k, v in pairs(loadedTattoos) do
                if v.Count ~= nil then
                    for i = 1, v.Count do
                        AddPedDecorationFromHashes(ped, v.collection, v.nameHash)
                    end
                else
                    AddPedDecorationFromHashes(ped, v.collection, v.nameHash)
                end
            end
        end
    end)
end

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




CreateThread(function()
    if Config.UseTarget then
        for k, v in pairs(Config.TattooZones) do
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
        for k, v in pairs(Config.TattooShops) do
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
    for k, v in pairs(Config.TattooShops) do
        local blip = AddBlipForCoord(v)
        SetBlipSprite(blip, 75)
        SetBlipColour(blip, 1)
        SetBlipScale(blip, 0.8)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("ParaTattoos")
        EndTextCommandSetBlipName(blip)
    end
end)

if Config.Debug then
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


    RegisterCommand('tattoo', function(source)
        TattooMenu()
    end)
end