local function RGBToLong(cor)
    return (cor.r * 65536) + (cor.g * 256) + cor.b
end

local function GetPlayer(identifier, notifySource)
    if tonumber(identifier) then
        return exports.qbx_core:GetPlayer(identifier)
    else
        return exports.qbx_core:GetPlayerByCitizenId(identifier)
    end
    lib.notify(notifySource, {description = "Jogador nao encontrado.", type = "error", duration = 5000})
    return false
end

local function AddCitizenship(citizenId, identifier)
    local status, err = pcall(MySQL.insert.await, "INSERT INTO `mri_qwhitelist` (citizen) VALUES (?)", {citizenId})

    if status then
        return true
    end
    print(string.format("identifier: %s", identifier))
    print(err)
    return false
end

local function RemoveCitizenship(citizenId, identifier)
    local status, err = pcall(MySQL.update.await, "DELETE FROM `mri_qwhitelist` WHERE `citizen` = ?", {citizenId})

    if status then
        return true
    end
    print(string.format("identifier: %s", identifier))
    print(err)
    return false
end

local function GetConfig()
    local SELECT_DATA = "SELECT * FROM mri_qwhitelistcfg"
    local result = MySQL.Sync.fetchAll(SELECT_DATA, {})
    if not result or #result == 0 then
        return false
    end
    Config = json.decode(result[1].config)
end

local function SetConfig(data)
    local INSER_DATA = "INSERT INTO `mri_qwhitelistcfg` (id, config) VALUES (?, ?) ON DUPLICATE KEY UPDATE `config` = ?"
    local result = MySQL.Sync.execute(INSER_DATA, {1, data, data})
end

local function SetPlayerBucket(target, bucket)
    local actualBucket = GetPlayerRoutingBucket(target)
    if actualBucket == bucket then
        return
    end
    exports.qbx_core:SetPlayerBucket(target, bucket)
end

local function Initialize()
    local success, result = pcall(MySQL.scalar.await, "SELECT 1 FROM mri_qwhitelist")

    if not success then
        MySQL.query(
            [[CREATE TABLE IF NOT EXISTS `mri_qwhitelist` (
        `id` INT NOT NULL AUTO_INCREMENT,
        `citizen` VARCHAR(50) NOT NULL,
        PRIMARY KEY (`id`),
        UNIQUE KEY `citizen` (`citizen`)
        )]]
        )
        print("[mri_Qbox] Deployed database table for mri_qwhitelist")
    end

    success, result = pcall(MySQL.scalar.await, "SELECT 1 FROM mri_qwhitelistcfg")

    if not success then
        MySQL.query.await(
            [[CREATE TABLE IF NOT EXISTS `mri_qwhitelistcfg` (
        `id` INT NOT NULL AUTO_INCREMENT,
        `config` LONGTEXT NOT NULL,
        PRIMARY KEY (`id`)
        )]]
        )
        print("[mri_Qbox] Deployed database table for mri_qwhitelistcfg")
    end

    GetConfig()
end

AddEventHandler(
    "onResourceStart",
    function(resource)
        if resource == GetCurrentResourceName() then
            Initialize()
        end
    end
)

lib.callback.register(
    "mri_Qwhitelist:Server:GetConfig",
    function(source)
        return Config
    end
)

lib.callback.register(
    "mri_Qwhitelist:Server:SaveConfig",
    function(source, data)
        SetConfig(json.encode(data))
        Config = data
        print("[mri_Qwhitelist] Config saved")
        return true
    end
)

lib.callback.register(
    "mri_Qwhitelist:Server:CheckCitizenship",
    function(source)
        if Config.Enabled == false then
            return true
        end
        local playerBucket = 1000 + source
        exports.qbx_core:SetPlayerBucket(source, playerBucket)
        local player = exports.qbx_core:GetPlayer(source)
        local citizenid = player.PlayerData.citizenid
        local row = MySQL.single.await("SELECT * FROM `mri_qwhitelist` WHERE `citizen` = ? LIMIT 1", {citizenid})
        if row then
            exports.qbx_core:SetPlayerBucket(source, 0)
            return true
        end
        return false
    end
)

lib.callback.register(
    "mri_Qwhitelist:Server:AddCitizenship",
    function(source, identifier)
        local player = GetPlayer(identifier or source, identifier and source or nil)
        if not player then
            return false
        end

        local status = AddCitizenship(player.PlayerData.citizenid, identifier or source)
        if not status then
            if identifier then
                lib.notify(
                    source,
                    {
                        description = "Erro ao liberar player, verifique o console para mais informações.",
                        type = "error",
                        duration = 5000
                    }
                )
            end
            return status
        end

        SetPlayerBucket(player.PlayerData.source, 0)
        lib.callback.await("mri_Qwhitelist:Client:AddCitizenship", player.PlayerData.source, false)
        return status
    end
)

lib.callback.register(
    "mri_Qwhitelist:Server:RemoveCitizenship",
    function(source, identifier)
        local player = GetPlayer(identifier)
        if not player then
            return false
        end

        local status = RemoveCitizenship(player.PlayerData.citizenid, identifier)
        if not status then
            lib.notify(
                source,
                {
                    description = "Erro ao revogar whitelist, verifique o console para mais informações.",
                    type = "error",
                    duration = 5000
                }
            )
        end

        SetPlayerBucket(player.PlayerData.source, 1000 + player.PlayerData.source)
        lib.callback.await("mri_Qwhitelist:Client:RemoveCitizenship", player.PlayerData.source, false)
        return status
    end
)

lib.callback.register(
    "mri_Qwhitelist:Server:SendPreExamData",
    function(source, data)
        if not Config.PreExamQuestions.WebHook then
            print("Sem webhook para enviar os dados...")
            return
        end
        local color =
            RGBToLong(
            {
                r = 0,
                g = 255,
                b = 255
            }
        )
        local player = GetPlayer(source)
        if not player then
            return
        end
        local fields = {
            {
                name = "Identificador:",
                value = player.PlayerData.name,
                inline = true
            },
            {
                name = "CitizenID:",
                value = player.PlayerData.citizenid,
                inline = true
            },
            {
                name = "Nome do Player:",
                value = string.format(
                    "%s %s",
                    player.PlayerData.charinfo.firstname,
                    player.PlayerData.charinfo.lastname
                ),
                inline = false
            }
        }
        for k, v in pairs(data) do
            local value = v.value
            if v.kind == "phone" and Config.PreExamQuestions.FormatPhone then
                value = string.format("https://wa.me/55%s", value)
            end
            fields[#fields + 1] = {
                name = k,
                value = value,
                inline = false
            }
        end
        local obj =
            json.encode(
            {
                embeds = {
                    {
                        title = "Dados Pré-Exame",
                        fields = fields,
                        footer = {
                            text = "MRI QBOX ⋅ " .. os.date("%d/%m/%Y %X"),
                            icon_url = "https://republica.warleynutricionista.workers.dev/logo.gif"
                        },
                        color = color
                    }
                }
            }
        )
        PerformHttpRequest(
            Config.PreExamQuestions.WebHook,
            function(errorCode, resultData, resultHeaders, errorData)
                if Config.DebugHook then
                    print(
                        string.format(
                            "Webhook:\n\tCódigo: %s\n\tResultado: %s\n\tErro: %s",
                            errorCode,
                            ttc.shared.toString(resultData),
                            ttc.shared.toString(errorData)
                        )
                    )
                end
            end,
            "POST",
            obj,
            {
                ["Content-Type"] = "application/json"
            }
        )
    end
)
