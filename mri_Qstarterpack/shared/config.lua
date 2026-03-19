Config = {}

--[[
▀█▀ █▀▀ █▀▀ ▀█ █▄█   █▀▀ █▀█ █▀█ █▀▀   █▀▄ █▀▀ █░█ █▀▀ █░░ █▀█ █▀█ █▀▄▀█ █▀▀ █▄░█ ▀█▀
░█░ ██▄ ██▄ █▄ ░█░   █▄▄ █▄█ █▀▄ ██▄   █▄▀ ██▄ ▀▄▀ ██▄ █▄▄ █▄█ █▀▀ █░▀░█ ██▄ █░▀█ ░█░

    Documentação: https://tcdev.gitbook.io/tcd-documentation/free-release/advanced-starterpack-system
]]

Config.Debug = false                      -- habilita modo debug para ver mais informações no console
Config.CheckVersion = true                -- verifica a versão mais recente do script
Config.DBChecking = true                  -- checa se a tabela/colunas do banco estão criadas corretamente (ative apenas se tiver problemas no DB)
Config.CheckPacksCommand = 'checkpacks'   -- comando para listar todos os jogadores que já receberam o kit inicial

Config.TargetResource = 'ox_target'       -- suportado: ox_target, qb-target
Config.InventoryResource =
'ox_inventory'                            -- suportado: ox_inventory, qb-inventory, ps-inventory, qs-inventory, codem-inventory
Config.SQLResource = 'oxmysql'            -- suportado: oxmysql, mysql-async, ghmattimysql

Config.UsePlayerLicense = true            -- usar a licença do jogador para verificar se já recebeu o kit inicial

Config.UseTarget = true                   -- habilita o sistema de target para interagir com os NPCs
Config.Use3DText = false                  -- habilita texto 3D para mostrar o texto de interação

Config.CommandConfig = {                  -- comando para entregar o kit inicial
    enable           = false,
    command          = 'starterpack',
    command_help     = 'Receba seu kit inicial',
    starterpack_type = 'normal',
    starter_vehicle  = {
        enable = true,
        model = 'adder',
        random_vehicle = false,
    }
}

Config.DialogInfo = { -- configurações do diálogo do kit inicial
    enable = true,
    title = 'Kit Inicial',
    dialog_type = 'rules', -- tipos disponíveis: rules, quiz, captcha (apenas UM pode estar ativo)
    alert_description = 'Você receberá o Kit Inicial após aceitar as regras e concluir o quiz/captcha.',

    quiz = {
        questions = {
            {
                question = 'O que mantém a imersão do Roleplay?',
                description = 'Conceitos básicos de RP.',
                answers = {
                    { label = 'Permanecer em personagem e agir coerente com a história', correct = true },
                    { label = 'Sair do personagem quando conveniente',                     correct = false },
                    { label = 'Ignorar outros jogadores',                                   correct = false },
                    { label = 'Usar informações de fora do jogo (OOC) em IC',              correct = false },
                }
            },
            {
                question = 'O que é Metagaming (META)?',
                description = 'Regras essenciais de conduta.',
                answers = {
                    { label = 'Usar informação OOC em situações IC',         correct = true },
                    { label = 'Atacar sem motivo de RP (RDM)',               correct = false },
                    { label = 'Forçar ações impossíveis (PG)',               correct = false },
                    { label = 'Interpretar um emprego legal no servidor',    correct = false },
                }
            },
            {
                question = 'O que é RDM?',
                description = 'Termos comuns de RP.',
                answers = {
                    { label = 'Matar/atacar sem motivo ou contexto de RP',   correct = true },
                    { label = 'Bater com veículo em outros propositalmente', correct = false },
                    { label = 'Sair do personagem em cena',                  correct = false },
                    { label = 'Negociar com facções de forma coerente',      correct = false },
                }
            },
        }
    },

    captcha = {
        captcha_type = 'ra' -- rl: letras aleatórias | rn: números aleatórios | ra: alfanumérico aleatório
    },

    -- REGRAS PRINCIPAIS (curtas e contextuais)
    rules = {
        {
            title = 'Roleplay (RP) e Imersão',
            description = 'Interprete seu personagem o tempo todo (IC). Aja com coerência à história e objetivos dele.',
        },
        {
            title = 'Anti-RP',
            description = 'Evite ações que destruam a imersão (ex.: abandonar a persona/combinar OOC para resolver IC).',
        },
        {
            title = 'Metagaming (META)',
            description = 'Proibido usar informações de fora do jogo (Discord/stream/DM) para ganhar vantagem em IC.',
        },
        {
            title = 'Power Gaming (PG)',
            description = 'Não force ações impossíveis/irrealistas ou que retirem a chance de reação do outro jogador.',
        },
        {
            title = 'RDM / VDM',
            description = 'Proibido atacar/matar sem motivo de RP (RDM) e usar veículo como arma sem contexto (VDM).',
        },
        {
            title = 'História do Personagem (Legal x Ilegal)',
            description = 'Caminhos legais/ilegais são válidos; mantenha coerência com sua história e consequências.',
        },
        {
            title = 'Convivência e Staff',
            description = 'Respeite todos. Siga orientações da Staff. Quebras de regra podem resultar em punições.',
        },
    }
}


Config.Locations = {
    ["1"] = {                                                                       -- Identificador único da localização
        starterpack_type = 'normal',                                                -- Tipo do kit entregue (defina false para não dar item de kit)
        label            = 'Receba seu kit inicial',                                -- Texto no alvo (mostrado ao jogador)
        icon             = 'fa-solid fa-gift',                                      -- Ícone do alvo (FontAwesome)

        coords           = vec4(-1040.479126, -2731.582520, 20.164062, 238.110229), -- Coordenadas + heading do NPC

        ped              = {                                                        -- Configurações do ped (NPC)
            model = 'a_m_y_business_03',                                            -- Modelo do ped (veja lista de peds do FiveM)
            scenario = 'Standing',                                                  -- Cenário/animação do ped
        },

        safezone         = { -- zona segura (opcional)
            enable = false,  -- habilitar/desabilitar zona segura
            zone_points = {
                vec3(-1035.819, -2734.205, 20.169),
                vec3(-1035.999, -2727.598, 20.134),
                vec3(-1043.567, -2723.403, 20.126),
                vec3(-1049.598, -2731.540, 20.169),
                vec3(-1041.131, -2739.401, 20.169),
            } -- pontos da zona (se habilitada) usando vector3
        },

        starter_vehicle  = {         -- veículo inicial para quem receber
            enable = true,           -- habilitar/desabilitar veículo inicial
            model = 'adder',         -- modelo (ignorado se random_vehicle = true)
            random_vehicle = true,   -- sorteia veículo da lista (true/false)
            teleport_player = false, -- teleporta o jogador para o veículo (true/false)
            vehicle_spawns = {       -- pontos de spawn (vários)
                vec4(-1039.02, -2727.53, 19.65, 243.17),
                vec4(-1043.3, -2725.09, 19.65, 241.12),
                vec4(-1047.57, -2722.66, 19.65, 240.54),
                vec4(-1034.38, -2719.0, 19.65, 240.52),
                vec4(-1038.51, -2716.53, 19.64, 240.34),
            },
            fuel = 100.0, -- nível de combustível ao spawnar
        },

        receiving_radius = 20.0, -- raio em volta do ponto onde o jogador pode receber o kit
        distance         = 2.0,  -- distância do ped para interagir
    },
    -- adicione mais localizações aqui
}

Config.RandomVehicles = { -- lista de veículos para sorteio
    vehicles = {
        "adder",
        "zentorno",
        "t20",
        "osiris",
        "reaper",
        "tempesta",
        "italigtb",
        "italigtb2",
        "nero",
        -- adicione mais veículos aqui
    }
}

Config.StarterPackItems = { -- itens entregues ao jogador
    ["normal"] = {
        { item = 'burger',   amount = 5 },
        { item = 'sprunk',   amount = 5 },
        { item = 'phone',    amount = 1 },
        { item = 'lockpick', amount = 5 },
        { item = 'money',    amount = 5000 },
    },
    -- adicione mais tipos de kit aqui
}

---@param vehicle any
---@param fuel number
---@description Define o combustível do veículo usando o recurso de combustível instalado
Config.SetFuel = function(vehicle, fuel)
    if GetResourceState("LegacyFuel") == "started" then
        exports['LegacyFuel']:SetFuel(vehicle, fuel)
    elseif GetResourceState("cdn-fuel") == "started" then
        exports['cdn-fuel']:SetFuel(vehicle, fuel)
    elseif GetResourceState("ps-fuel") == "started" then
        exports['ps-fuel']:SetFuel(vehicle, fuel)
    elseif GetResourceState("lj-fuel") == "started" then
        exports['lj-fuel']:SetFuel(vehicle, fuel)
    elseif GetResourceState("ox_fuel") == "started" then
        Entity(vehicle).state.fuel = fuel
    else
        warn("Recurso de combustível não encontrado. Configure seu recurso de combustível no config.lua.")
        SetVehicleFuelLevel(vehicle, fuel) -- fallback: sistema padrão de combustível
    end
end

---@param vehicle any
---@return string
---@description Se você usa um sistema de chaves customizado, entregue a chave ao jogador
Config.GiveKey = function(vehicle, plate)
    if GetResourceState("wasabi_carlock") == "started" then
        exports.wasabi_carlock:GiveKey(plate)
    elseif GetResourceState("jaksam-vehicles-keys") == "started" then
        TriggerServerEvent("vehicles_keys:selfGiveVehicleKeys", plate)
    elseif GetResourceState("cd_garage") == "started" then
        TriggerEvent('cd_garage:AddKeys', plate)
    elseif GetResourceState("okokGarage") == "started" then
        TriggerServerEvent("okokGarage:GiveKeys", plate)
    elseif GetResourceState("t1ger_keys") == "started" then
        TriggerServerEvent('t1ger_keys:updateOwnedKeys', plate, true)
    elseif GetResourceState("ak47_vehiclekeys") == "started" then
        exports['ak47_vehiclekeys']:GiveKey(plate, false)
    else
        TriggerEvent("vehiclekeys:client:SetOwner", plate)
    end
end

---@param message string
---@param type string
---@param is_server boolean
---@description Envia uma notificação ao jogador
Config.Notification = function(message, type, is_server, src)
    local Core, Framework = GetCore()
    if is_server then
        if Framework == "esx" then
            TriggerClientEvent("esx:showNotification", src, message)
        else
            TriggerClientEvent('QBCore:Notify', src, message, type, 5000)
        end
    else
        if Framework == "esx" then
            -- TriggerEvent("esx:showNotification", message)
            Core.ShowNotification(message, type, 5000)
        else
            Core.Functions.Notify(message, type, 5000)
        end
    end
end
