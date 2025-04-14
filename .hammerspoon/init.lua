hs.loadSpoon("SpoonInstall")

--------------------------------
-- START VIM CONFIG
--------------------------------
local VimMode = hs.loadSpoon("VimMode")
local vim = VimMode:new()

-- Configure apps you do *not* want Vim mode enabled in
-- For example, you don't want this plugin overriding your control of Terminal
-- vim
vim:disableForApp("Code")
vim:disableForApp("zoom.us")
vim:disableForApp("iTerm2")
vim:disableForApp("Terminal")
vim:disableForApp("Ghostty")
vim:disableForApp("Ghostty.app")
vim:disableForApp("Google Chrome")

-- If you want the screen to dim (a la Flux) when you enter normal mode
-- flip this to true.
vim:shouldDimScreenInNormalMode(false)

-- If you want to show an on-screen alert when you enter normal mode, set
-- this to true
vim:shouldShowAlertInNormalMode(true)

-- You can configure your on-screen alert font
vim:setAlertFont("Courier New")

-- Enter normal mode by typing a key sequence
-- vim:enterWithSequence("jk")
-- Only execute in Hammerspoon environment
if hs then
	vim:bindHotKeys({ enter = { {}, "escape" } })
end

--------------------------------
-- END VIM CONFIG
--------------------------------
