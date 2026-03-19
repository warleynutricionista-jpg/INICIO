Config = {
    Enabled = true, -- Coloque false para desativar a whitelist.
    Debug = false, -- Coloque true para habilitar o debug.
    Percent = 70, -- Porcentagem de respostas corretas para liberar o player
    loadNotify = "Você deve completar o exame de cidadania para jogar!", -- Notification when player loads in without completing citizenship.
    escapeNotify = "Você deve completar o exame de cidadania para jogar!", -- Notification when player tries to leave citizenship office.
    -- Labels for Exam:
    StartExamLabel = "Iniciar o exame de cidadania",
    StartExamHeader = "Exame de cidadania",
    StartExamContent = "Todos os novos cidadãos devem passar no exame antes que possam jogar. Faça no seu tempo, responda com bom senso e não responda aleatoriamente.",
    SuccessHeader = "Você passou no exame de cidadania!",
    SuccessContent = "Bem-vindo ao nosso servidor!",
    FailedHeader = "Você falhou no exame de cidadania!",
    FailedContent = "Por favor, tente novamente.",
    PassingScore = 4, -- Amount of value questions required to get citizenship.
    NotifyType = "ox_lib", -- Support for 'ox_lib', 'qb', 'esx', 'okok' and 'custom' to use a different type.
    Interaction = {
        Type = "target", -- Supports 'marker' and 'target' and '3dtext'
        MarkerLabel = "Comece o exame de cidadania",
        MarkerType = 27, -- https://docs.fivem.net/docs/game-references/markers/
        MarkerColor = {r = 26, g = 115, b = 179}, -- RGB Color picker: https://g.co/kgs/npUqed1
        MarkerSize = {x = 1.0, y = 1.0, z = 1.0},
        MarkerOnFloor = false,
        TargetIcon = "fas fa-passport", -- https://fontawesome.com/icons
        TargetLabel = "Comece o exame de cidadania",
        TargetRadius = vector3(4, 4, 4),
        TargetDistance = 2.0
    },
    -- DO NOT MODIFY UNLESS YOU ARE GOING TO MODIFY citizenZone.
    SpawnCoords = vec4(-66.24, -822.09, 285.61 - 1, 78.8),
    ExamCoords = vec3(-68.24, -814.40, 285.35), -- vec3(-1372.2820, -465.5251, 71.8305)
    CompletionCoords = vec4(-1042.68, -2745.97, 21.36, 323.7),
    citizenZone = {
        -- Can be created through /zone box
        coords = vec3(-73.34, -821.15, 285.0),
        size = vec3(28.0, 22.2, 6.2),
        rotation = 340.0
    },
    Questions = {
        {
            question = "O que é Meta Gaming?",
            options = {
                {
                    label = "Metagaming é o uso de qualquer informação que seu personagem não aprendeu dentro do roleplay na cidade.",
                    value = true
                },
                {
                    label = "Metagaming é quando você tenta vender pés de galinha para as pessoas e você não tem nenhum pé de galinha.",
                    value = false
                },
                {label = "Eu não sei.", value = false},
                {label = "Metagaming é quando você não teme pela sua vida.", value = false}
            }
        },
        {
            question = "O que é Power Gaming?",
            options = {
                {
                    label = "Powergaming é o uso de formas de roleplay irreais ou a recusa total de fazer roleplay para se dar uma vantagem injusta.",
                    value = true
                },
                {
                    label = "Powergaming é o uso do cartão de crédito da sua mãe para comprar Fundador Suporte ;)",
                    value = false
                },
                {label = "Powergaming é quando você invade o clube de alguém usando exploits.", value = false},
                {label = "Eu não sei.", value = false}
            }
        },
        {
            question = "Você pode usar software de trapaça de terceiros?",
            options = {
                {label = "Isso não é permitido sob nenhuma circunstância.", value = true},
                {label = "Sim, claro, eu adoro eulen!", value = false},
                {label = "Somente se você pedir permissão para sua mãe.", value = false},
                {label = "Eu não sei.", value = false}
            }
        },
        {
            question = "Qual dos exemplos abaixo é uma Zona Verde?",
            options = {
                {label = "Hospitais.", value = true},
                {label = "Bancos de parque.", value = false},
                {label = "Em todos os lugares.", value = false},
                {label = "Todos os itens acima", value = false}
            }
        },
        {
            question = "O que significa quebrar o personagem?",
            options = {
                {label = "Quando você fala fora do personagem dentro da cidade.", value = true},
                {label = "Quando você quebra o personagem de outro jogador.", value = false},
                {label = "Quando seu tio não vem te buscar na escola.", value = false},
                {label = "Eu não sei.", value = false}
            }
        },
        {
            question = "Qual destes exemplos é da Regra de Morte Aleatória?",
            options = {
                {
                    label = "Você não pode atacar outro jogador aleatoriamente sem primeiro se envolver em algum tipo de RP verbal.",
                    value = true
                },
                {label = "Você pode matar outros jogadores sem motivo.", value = false},
                {label = "Você não pode comprar água a menos que seja um apoiador do servidor.", value = false},
                {label = "Eu não sei.", value = false}
            }
        }
    },
    PreExamQuestions = {
        Enabled = false,
        FormatPhone = true,
        WebHook = "", -- Discord Webhook URL
        label = "Precisamos de algumas informações:",
        information = {
            {
                type = "input", -- https://docs.mriqbox.com.br/overextended/ox_lib/Modules/Interface/Client/input#field-type-properties
                label = "Qual seu nome completo (Vida Real):",
                placeholder = "Seu nome",
                required = true,
                min = 3,
                max = 100,
                kind = "name"
            },
            {
                type = "input", -- https://docs.mriqbox.com.br/overextended/ox_lib/Modules/Interface/Client/input#field-type-properties
                label = "Qual o seu e-mail?",
                placeholder = "seu@email.com",
                min = 7,
                max = 50,
                required = true,
                kind = "email"
            },
            {
                type = "number", -- https://docs.mriqbox.com.br/overextended/ox_lib/Modules/Interface/Client/input#field-type-properties
                label = "Qual o seu WhatsApp?",
                placeholder = "9999999999",
                required = true,
                kind = "phone"
            },
        }
    }
}
