Text = {
    LoadInteractions = function(self, data)
        if Config.Interaction.Type ~= "3dtext" then
            return
        end

        local point =
            lib.points.new(
            {
                coords = Config.ExamCoords,
                distance = 8
            }
        )

        function point:nearby()
            local onScreen, _x, _y =
                World3dToScreen2d(Config.ExamCoords.x, Config.ExamCoords.y, Config.ExamCoords.z + 1)
            if onScreen then
                SetTextScale(0.4, 0.4)
                SetTextFont(4)
                SetTextProportional(1)
                SetTextColour(255, 255, 255, 255)
                SetTextOutline()
                SetTextEntry("STRING")
                SetTextCentre(true)
                AddTextComponentString("[~b~E~w~] " .. Config.Interaction.MarkerLabel .. "")
                DrawText(_x, _y)
            end
            if self.currentDistance < 3 and IsControlJustReleased(0, 38) then
                data.callbackFunction()
            end
        end
    end
}
