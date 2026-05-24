local text = Drawing.new("Text")
local camera = workspace.CurrentCamera


text.Text = "this script version not updated :( discord.gg/moonshine"
text.Size = 30
text.Color = Color3.fromRGB(255, 255, 255)
text.Outline = true
text.Visible = true


local function centerText()
    local viewportSize = camera.ViewportSize
    text.Position = Vector2.new(
        (viewportSize.X / 2) - (text.TextBounds.X / 2),
        (viewportSize.Y / 2) - (text.TextBounds.Y / 2)
    )
end


centerText()


local connection
connection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    centerText()
end)
