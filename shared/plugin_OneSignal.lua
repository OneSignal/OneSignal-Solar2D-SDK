local Library = require "CoronaLibrary"

-- OneSignal.lua
-- This is a lua shell that calls into native iOS and Android libraries.

-- Create library
local OneSignalObject = Library:new{ name='OneSignal', publisherId='REVERSE_PUBLISHER_URL' }

-------------------------------------------------------------------------------
-- BEGIN (Insert your implementation startine here)
-------------------------------------------------------------------------------

local function GetVersion()
	return "1.15.6"
end

local json = require "json"
local OneSignalNative = require("OneSignal") -- Native part of the OneSignal SDK



OneSignalObject.TagPlayerWithTable = function(keyValueTable)
	print("TagPlayerWithTable is deprecated please use OneSignal.SendTags")
	OneSignalNative.sendTags(json.encode(keyValueTable))
end

OneSignalObject.SendTags = function(keyValueTable)
	OneSignalNative.sendTags(json.encode(keyValueTable))
end

OneSignalObject.TagPlayer = function(key, value)
    print("TagPlayer is deprecated please use OneSignal.SendTag")
    OneSignalObject.SendTags({[key] = value})
end

OneSignalObject.SendTag = function(key, value)
    OneSignalObject.SendTags({[key] = value})
end

OneSignalObject.DeleteTags = function(keys)
	local deleteTags = {}
	for i, key in ipairs(keys) do
		deleteTags[key] = ""
	end

	OneSignalNative.sendTags(json.encode(deleteTags))
end

OneSignalObject.DeleteTag = function(key)
	OneSignalObject.DeleteTags({key})
end

OneSignalObject.GetTags = function(getTagsCallback)
	local localGetTagsCallback = function(tags)
		if (getTagsCallback) then
            if (tags) then
                getTagsCallback(json.decode(tags))
            else
                getTagsCallback(nil)
            end

		end
	end

	OneSignalNative.getTags(localGetTagsCallback)
end

OneSignalObject.DisableAutoRegister = function()
	if (system.getInfo("platformName") == "iPhone OS") then
		OneSignalNative.disableAutoRegister()
	end
end

OneSignalObject.RegisterForNotifications = function()
	if (system.getInfo("platformName") == "iPhone OS") then
		OneSignalNative.registerForNotifications()
	end
end

OneSignalObject.Init = function(appid, googleProjectNum, notificationOpenedCallback)
	print("Starting Corona OneSignal SDK v" .. GetVersion())
	local localNotificationOpenedCallback = function(message, additionalData, isActive)
		if (notificationOpenedCallback) then
            if (additionalData) then
			    notificationOpenedCallback(message, json.decode(additionalData), isActive)
            else
                notificationOpenedCallback(message, null, isActive)
            end
        end
	end

	OneSignalNative.init(appid, googleProjectNum, localNotificationOpenedCallback)
end

OneSignalObject.SetInAppMessageClickHandler = function(inAppMessageClickCallback)
	local localInAppMessageClickCallback = function(actionJson)
		if (inAppMessageClickCallback) then
			if (actionJson) then
			    inAppMessageClickCallback(json.decode(actionJson))
            else
                inAppMessageClickCallback(nil)
            end
		end
	end

	OneSignalNative.setInAppMessageClickHandler(localInAppMessageClickCallback)
end

OneSignalObject.IdsAvailableCallback = function(callback)
	OneSignalNative.idsAvailable(callback)
end

OneSignalObject.ClearAllNotifications = function()
	OneSignalNative.clearAllNotifications()
end

OneSignalObject.EnableVibrate = function(enable)
	if (system.getInfo("platformName") == "Android") then
		OneSignalNative.enableVibrate(enable)
	end
end

OneSignalObject.EnableSound = function(enable)
	if (system.getInfo("platformName") == "Android") then
		OneSignalNative.enableSound(enable)
	end
end

OneSignalObject.EnableNotificationsWhenActive = function(enable)
	if (system.getInfo("platformName") == "Android") then
		OneSignalNative.enableNotificationsWhenActive(enable)
	end
end

OneSignalObject.EnableInAppAlertNotification = function(enable)
   OneSignalNative.enableInAppAlertNotification(enable)
end

OneSignalObject.SetSubscription = function(enable)
   OneSignalNative.setSubscription(enable)
end

OneSignalObject.StaticOnSuccessCallback = nil
OneSignalObject.StaticOnFailureCallback = nil

OneSignalObject.PostNotification = function(data, onSuccessCallback, onFailureCallback)
	OneSignalObject.StaticOnSuccessCallback = onSuccessCallback
	OneSignalObject.StaticOnFailureCallback = onFailureCallback

	OneSignalNative.postNotification(json.encode(data),
		function(jsonStr) -- onSuccess
			OneSignalObject.StaticOnFailureCallback = nil
			if (OneSignalObject.StaticOnSuccessCallback) then
				local decoded, pos, msg = json.decode(jsonStr)
				OneSignalObject.StaticOnSuccessCallback(decoded)
				OneSignalObject.StaticOnSuccessCallback = nil
			end
		end,
		function(jsonStr) -- onFailure
			OneSignalObject.StaticOnSuccessCallback = nil
			if (OneSignalObject.StaticOnFailureCallback) then
				local decoded, pos, msg = json.decode(jsonStr)
				OneSignalObject.StaticOnFailureCallback(decoded)
				OneSignalObject.StaticOnFailureCallback = nil
			end
		end
	);
end

OneSignalObject.SetEmail = function(email)
	OneSignalNative.setEmail(email)
end

OneSignalObject.PromptLocation = function()
	OneSignalNative.promptLocation()
end

OneSignalObject.SetLogLevel = function(logLevel, visualLevel)
	OneSignalNative.setLogLevel(logLevel, visualLevel)
end

OneSignalObject.AddTrigger = function(key, value)
	OneSignalNative.addTrigger(json.encode({[key] = value}))
end

OneSignalObject.AddTriggers = function(triggers)
	OneSignalNative.addTriggers(json.encode(triggers))
end

OneSignalObject.RemoveTriggerForKey = function(key)
	OneSignalNative.removeTriggerForKey(key)
end

OneSignalObject.RemoveTriggersForKeys = function(keys)
	OneSignalNative.removeTriggersForKeys(json.encode(keys))
end

OneSignalObject.GetTriggerValueForKey = function(key, callback)
	OneSignalNative.getTriggerValueForKey(key, callback)
end

OneSignalObject.PauseInAppMessages = function(pause)
	OneSignalNative.pauseInAppMessages(pause)
end

-------------------------------------------------------------------------------
-- END
-------------------------------------------------------------------------------

-- Return an instance
return OneSignalObject
