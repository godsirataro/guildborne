--!strict
-- Presentation tokens share the established art palette. No external font assets.
local art = require(game.ReplicatedStorage.Shared.Config.Art)
local colors = art.UI
return table.freeze({
	Colors = table.freeze({
		Background = colors.Background, Surface = colors.Card, Text = colors.Text,
		Muted = colors.Muted, Gold = colors.Accent, Primary = colors.Button,
		Border = colors.Border, Focus = art.Palette.Magic,
	}),
	Fonts = table.freeze({ Heading = Enum.Font.GothamBold, Body = Enum.Font.GothamMedium }),
	Spacing = table.freeze({ Small = 8, Medium = 16, Large = 24 }),
	MinimumTarget = 48,
})
