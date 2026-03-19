# Auditoria técnica — personagem / multichar / delete character

## Resumo

### Causa raiz principal (criação)
O fluxo interno de criação do `qbx_core` chama `TriggerEvent('qb-clothes:client:CreateFirstCharacter')`, mas o listener desse evento fica dentro do modo **QB** do `illenium-appearance`, e esse modo só inicializa quando `GetResourceState("qb-core") ~= "missing"`. Nesta árvore o core real é `qbx_core`, não `qb-core`, então o listener pode não registrar. Resultado: o core salva o personagem, entrega starter items e deixa a tela em fade/preta, mas o criador de aparência não abre.

### Causa raiz principal (delete)
O `qbx_core` tenta deletar dados do personagem em `properties.owner` por configuração estática. O erro informado prova que no banco atual **existe a tabela `properties`, mas não existe a coluna `owner`**. Isso quebra a transação inteira de exclusão.

### Secundárias críticas
1. Mesmo que o `CreateFirstCharacter` abra, o `qbx_core` espera o evento `qbx_core:client:firstCharacterAppearanceFinished`, e não há bridge/listener correspondente nesta árvore.
2. `startingApartment = true`, mas o fluxo do core procura `qbx_apartments` / `qbx_spawn`; a árvore possui `qbx_properties` e não possui `qbx_apartments` nem `qbx_spawn`.
3. O `qbx_properties` versionado aqui está parcialmente desativado (`server_scripts` comentados no `fxmanifest`).
4. O `qbx_properties/client/apartmentselect.lua` mistura `sharedConfig.apartmentOptions` com `apartmentOptions` populado por `ps-housing:setApartments`, deixando um caminho inconsistente.
5. `qbx-multicharacter` legado está presente e usa nomes antigos/renomeados (`qbx-core`, `qbx-apartments`). Se estiver ensured junto com o multichar interno do `qbx_core`, o ambiente fica duplicado/conflitante.

## Patch sugerido (não aplicado automaticamente)

### Opção A — manter multichar interno do qbx_core
- Corrigir integração do `illenium-appearance` para reconhecer `qbx_core`.
- Criar bridge ao concluir aparência para disparar `qbx_core:client:firstCharacterAppearanceFinished`.
- Desativar dependência de apartamento inicial até haver um recurso de spawn/apartment coerente.

```diff
--- a/illenium-appearance/shared/framework/framework.lua
+++ b/illenium-appearance/shared/framework/framework.lua
@@
 function Framework.QBCore()
-    return GetResourceState("qb-core") ~= "missing"
+    return GetResourceState("qb-core") ~= "missing" or GetResourceState("qbx_core") ~= "missing"
 end
```

```diff
--- a/illenium-appearance/client/framework/qb/main.lua
+++ b/illenium-appearance/client/framework/qb/main.lua
@@
-local QBCore = exports["qb-core"]:GetCoreObject()
+local coreResource = GetResourceState("qb-core") ~= "missing" and "qb-core" or "qbx_core"
+local QBCore = exports[coreResource]:GetCoreObject()
```

```diff
--- a/illenium-appearance/client/client.lua
+++ b/illenium-appearance/client/client.lua
@@
         if (appearance) then
             TriggerServerEvent("illenium-appearance:server:saveAppearance", appearance)
+            TriggerEvent('qbx_core:client:firstCharacterAppearanceFinished')
             if onSubmit then
                 onSubmit()
             end
```

```diff
--- a/qbx_core/config/client.lua
+++ b/qbx_core/config/client.lua
@@
-        startingApartment = true,
+        startingApartment = false,
```

### Opção B — usar housing real diferente de qbx_properties
Se o servidor usa outra tabela `properties` (por exemplo schema legado de outro housing), **não** mantenha `{'properties', 'owner'}` no `characterDataTables` do core. Troque pela tabela/coluna real do seu housing.

```diff
--- a/qbx_core/config/server.lua
+++ b/qbx_core/config/server.lua
@@
-        {'properties', 'owner'},
+        -- {'properties', 'owner'}, -- remova se o housing atual não usa este schema
```

### SQL sugerido caso o housing correto seja o qbx_properties oficial
Executar a migration/importação do schema oficial:

```sql
CREATE TABLE IF NOT EXISTS `properties` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `property_name` VARCHAR(255) NOT NULL,
    `coords` JSON NOT NULL,
    `price` INT NOT NULL DEFAULT 0,
    `owner` VARCHAR(50) COLLATE utf8mb4_unicode_ci,
    `interior` VARCHAR(255) NOT NULL,
    `keyholders` JSON NOT NULL DEFAULT (JSON_OBJECT()),
    `rent_interval` INT DEFAULT NULL,
    `interact_options` JSON NOT NULL DEFAULT (JSON_OBJECT()),
    `stash_options` JSON NOT NULL DEFAULT (JSON_OBJECT()),
    FOREIGN KEY (owner) REFERENCES `players` (`citizenid`),
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

## Validações práticas recomendadas
1. Verificar se **somente um** sistema de multichar está ensured.
2. Confirmar em runtime o resultado de `GetResourceState('qb-core')`, `GetResourceState('qbx_core')`, `GetResourceState('illenium-appearance')`, `GetResourceState('qbx_properties')`, `GetResourceState('qbx_apartments')`, `GetResourceState('qbx_spawn')`, `GetResourceState('mri_Qspawn')`.
3. Instrumentar logs temporários antes/depois de:
   - `qbx_core:server:createCharacter`
   - `TriggerEvent('qb-clothes:client:CreateFirstCharacter')`
   - submit do `InitializeCharacter`
   - `TriggerEvent('qbx_core:client:firstCharacterAppearanceFinished')`
   - `storage.deletePlayer(citizenId)`
4. Rodar `SHOW COLUMNS FROM properties;` e alinhar o mapping de delete com o housing real.
