Zone = {
    Zone = nil,
    Load = function(self, data)
        if data.type == "box" then
            Zone.Zone = lib.zones.box(data.zoneData)
        end
    end,
    Remove = function(self)
        if Zone.Zone then
            Zone.Zone:remove()
            Zone.Zone = nil
        end
    end
}
