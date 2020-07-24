-----------------------------------------------------------------------------------------
--
-- view1.lua
--
-----------------------------------------------------------------------------------------

local json = require "json"
local widget = require( "widget" )
local composer = require( "composer" )
local OneSignal = require( "plugin.OneSignal" )

local scene = composer.newScene()

function GetYSpacingFromButton( button, padding )
	return button.y + button.height + padding
end

function scene:create( event )
	local sceneGroup = self.view

	-- Called when the scene's view does not exist.
	--
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	-- create a white background to fill screen
	local background = display.newRect( display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight )
	background:setFillColor( 1 )	-- white

	local textOptions = {
    text = "",
    width = 280,
    fontSize = 14,
    align = "left"  -- Alignment parameter
	}
	local textBox = display.newText( textOptions )
	textBox:setFillColor( 0, 0, 0 )

	-- Send tags event handler
	local buttonHandlerSendTags = function( event )
		-- Send a single tag in key, value fashion
		OneSignal.SendTag( "CoronaTag1", "value1" )

		-- Send several tags at once using a table
		local tagsTable = {["CoronaTag2"] = "value2", ["CoronaTag3"] = "value3"}
		OneSignal.SendTags( tagsTable )

		textBox.text = "Sent tags\nCoronaTag1, value1\n['CoronaTag2'] = 'value2', ['CoronaTag3'] = 'value3'"
	end

	local getTagsCallback = function ( tags )
		local tagsString = json.encode(tags);
		textBox.text = tagsString
		print("TAGS: " .. tagsString)
	end

	local buttonHandlerGetTags = function( event )
		-- Send a single tag in key, value fashion
		OneSignal.GetTags( getTagsCallback )
	end

	-- START: Send tags button
	local sendTagsButton = widget.newButton(
	    {
				label = "Send Tags",
				emboss = true,
				shape = "roundedRect",
				width = 280,
				height = 40,
				emboss = true,
				cornerRadius = 4,
				fillColor = { default={ 0.9, 0.3, 0.3, 1 }, over={ 0.8, 0.3, 0.3, 1 } },
				strokeColor = { default={ 0.9, 0.3, 0.3, 1 }, over={ 0.8, 0.3, 0.3, 1 } },
				strokeWidth = 0,
				labelColor = { default={1, 1, 1, 1}, over={1, 1, 1, 1} }
	    }
	)
	sendTagsButton:addEventListener( "tap", buttonHandlerSendTags )
	sendTagsButton.x = display.contentCenterX; sendTagsButton.y = 30;
	-- END: Send tags button

	-- START: Get tags button
	local getTagsButton = widget.newButton(
	    {
				label = "Get Tags",
				emboss = true,
				shape = "roundedRect",
				width = 280,
				height = 40,
				emboss = true,
				cornerRadius = 4,
				fillColor = { default={ 0.9, 0.3, 0.3, 1 }, over={ 0.8, 0.3, 0.3, 1 } },
				strokeColor = { default={ 0.9, 0.3, 0.3, 1 }, over={ 0.8, 0.3, 0.3, 1 } },
				strokeWidth = 0,
				labelColor = { default={1, 1, 1, 1}, over={1, 1, 1, 1} }
	    }
	)
	getTagsButton:addEventListener( "tap", buttonHandlerGetTags )
	getTagsButton.x = display.contentCenterX; getTagsButton.y = GetYSpacingFromButton(sendTagsButton, 12);
	-- END: Get tags button

	textBox.x = display.contentCenterX; textBox.y = GetYSpacingFromButton(getTagsButton, 12);


	-- all objects must be added to group (e.g. self.view)
	sceneGroup:insert( background )
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		--
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
	end
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase

	if phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end
end

function scene:destroy( event )
	local sceneGroup = self.view

	-- Called prior to the removal of scene's "view" (sceneGroup)
	--
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
