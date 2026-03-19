ColorScheme = GlobalState.UIColors or {}
Config = {}
local examCompleted = false

local function shuffleData(t)
    local shuffled = {}
    for i = #t, 1, -1 do
        local rand = math.random(i)
        t[i], t[rand] = t[rand], t[i]
        table.insert(shuffled, t[i])
    end
    return shuffled
end

local function showDialog(type, data)
    if type == "alert" then
        return lib.alertDialog(data) == "confirm"
    else
        return lib.inputDialog(data)
    end
end

local function showAlertDialog(header, content, cancel, confirmLabel, cancelLabel)
    local data = {
        header = header,
        content = content,
        cancel = cancel or false,
        centered = true,
        labels = {
            confirm = confirmLabel or "Confirmar",
            cancel = cancelLabel or "Cancelar"
        }
    }
    return showDialog("alert", data)
end

local function askQuestion(question)
    local options = {}
    options[#options + 1] = {
        type = "select",
        options = shuffleData(question.options)
    }
    local input = lib.inputDialog(question.question, options)
    if not input then
        for k, v in pairs(options[1].options) do
            if v.value then
                return false
            end
            return false
        end
    else
        return input[1]
    end
end

local function teleportPlayer(player, coords)
    DoScreenFadeOut(800)
    Wait(800)
    SetEntityCoords(player, coords.x, coords.y, coords.z)
    SetEntityHeading(player, coords.h)
    DoScreenFadeIn(1000)
end

local function beginExam()
    local correctAnswers = 0
    local ped = PlayerPedId()
    if ped then
        if Config["PreExamQuestions"] and Config.PreExamQuestions["Enabled"] then
            local input = lib.inputDialog(Config.PreExamQuestions.label, Config.PreExamQuestions.information)
            if not input then
                return
            end
            local result = {}
            for k, v in pairs(Config.PreExamQuestions.information) do
                result[v.label] = {kind = v.kind, value = input[k]}
            end

            lib.callback.await("mri_Qwhitelist:Server:SendPreExamData", false, result)
        end
        if not showAlertDialog(Config.StartExamHeader, Config.StartExamContent, true, "Iniciar") then
            return
        end

        local score = 0
        local questions = shuffleData(Config.Questions)
        for _, question in ipairs(questions) do
            correctAnswers = correctAnswers + (askQuestion(question) and 1 or 0)
        end
        local anwserPercentage = ((100 * correctAnswers) / #Config.Questions)
        if anwserPercentage >= Config.Percent then
            showAlertDialog(Config.SuccessHeader, Config.SuccessContent, false, "Jogar")
            lib.callback.await("mri_Qwhitelist:Server:AddCitizenship", false)
        else
            showAlertDialog(Config.FailedHeader, Config.FailedContent, false, "Entendi")
        end
    end
end

local function escapeCitizenship()
    teleportPlayer(cache.ped, Config.SpawnCoords)
    lib.notify({description = Config.escapeNotify, type = "error"})
end

function loadCitizenship()
    teleportPlayer(cache.ped, Config.SpawnCoords)

    if Config.Interaction.Type == "marker" then
        Marker:LoadInteractions({callbackFunction = beginExam})
    elseif Config.Interaction.Type == "target" then
        if Target.TargetId then
            return
        end
        Target:LoadInteractions({callbackFunction = beginExam})
    elseif Config.Interaction.Type == "3dtext" then
        Text:LoadInteractions({callbackFunction = beginExam})
    end

    local zoneData = {
        name = "citizenZone",
        coords = Config.citizenZone.coords,
        size = Config.citizenZone.size,
        rotation = Config.citizenZone.rotation,
        debug = Config.Debug,
        onExit = escapeCitizenship
    }

    Zone:Load({type = "box", zoneData = zoneData})
    lib.notify({description = Config.loadNotify, type = "info"})
end

local function OnPlayerLoaded()
    Config = lib.callback.await("mri_Qwhitelist:Server:GetConfig", false)
    if not lib.callback.await("mri_Qwhitelist:Server:CheckCitizenship", false) then
        loadCitizenship()
    end
end

lib.callback.register(
    "mri_Qwhitelist:Client:AddCitizenship",
    function()
        examCompleted = true
        Zone:Remove()
        teleportPlayer(cache.ped, Config.CompletionCoords)
    end
)

lib.callback.register(
    "mri_Qwhitelist:Client:RemoveCitizenship",
    function()
        loadCitizenship()
    end
)

AddEventHandler(
    "onResourceStart",
    function(resourceName)
        if (GetCurrentResourceName() ~= resourceName) then
            return
        end
        OnPlayerLoaded()
    end
)

RegisterNetEvent(
    "QBCore:Client:OnPlayerLoaded",
    function()
        OnPlayerLoaded()
    end
)
