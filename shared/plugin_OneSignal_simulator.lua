local Library = require "CoronaLibrary"

-- Create library
local OneSignalObject = Library:new{ name='OneSignal', publisherId='REVERSE_PUBLISHER_URL' }

-------------------------------------------------------------------------------
-- BEGIN
-------------------------------------------------------------------------------

local function GetVersion()
	return "1.15.6"
end

-- Easy to use object to handle push notifications for you

OneSignalObject.TagPlayerWithTable = function(keyValueTable)
	print("TagPlayerWithTable is deprecated please use OneSignal.SendTags")
end

OneSignalObject.SendTags = function(keyValueTable)
	print("Called OneSignal.SendTags")
end

OneSignalObject.SendTag = function(key, value)
	print("Called OneSignal.SendTag(" .. key .. ", " .. value .. ")")
end

OneSignalObject.TagPlayer = function(key, value)
	print("TagPlayer is deprecated please use OneSignal.SendTag")
end

OneSignalObject.DisableAutoRegister = function()
	print("Called OneSignal.DisableAutoRegister()")
end

OneSignalObject.RegisterForNotifications = function()
	print("Called OneSignal.RegisterForNotifications()")
end

OneSignalObject.HandleLaunchArgs = function(launchArgs, appId, callback)
	print("ERROR!!!")
	print("HandleLaunchArgs is no longer vaild in this version of OneSignal.")
	print("Must use OneSignal.Init(appId, googleProjectNumber, DidReceiveRemoteNotification) instead.")
	print("You must also remove the whole notification = {} selection from your config.lua.")
	print('Lastly for iOS under plist = add UIBackgroundModes = {"remote-notification"},')
	print('Read our documentation or the Corona forums for more details.')
end

OneSignalObject.Init = function(appId, googleProjectNumber, notificationOpenedCallBack)
	print("Starting Corona OneSignal SDK v" .. GetVersion())
	print("WARNING: OneSignal does not run in the simulator, however you will see messages here when OneSignal methods are called for debuging.")
	print("NOTE: On a Android device watch the logcat or the Xcode log on iOS for messages to debug issues.")
	print("Called OneSignal.Init(" .. appId .. ", " .. googleProjectNumber .. ", callback)")
end

OneSignalObject.SetInAppMessageClickHandler = function(inAppMessageClickCallback)
	print("Called OneSignal.SetInAppMessageClickHandler()")
end

OneSignalObject.PlayerPurchase = function(amount)
	print("Called OneSignal.PlayerPurchase(" .. amount .. ")")
end

OneSignalObject.IdsAvailableCallback = function(callback)
	print("Called OneSignal.IdsAvailableCallback()")
end

OneSignalObject.GetTags = function(callback)
	print("Called OneSignal.GetTags")
end

OneSignalObject.DeleteTags = function(keys)
	print("Called OneSignal.DeleteTags")
end

OneSignalObject.DeleteTag = function(key)
	print("Called OneSignal.DeleteTag")
end

OneSignalObject.ClearAllNotifications = function()
	print("Called OneSignal.ClearAllNotifications")
end

OneSignalObject.EnableVibrate = function(enable)
	print("Called OneSignal.EnableVibrate")
end
OneSignalObject.EnableSound = function(enable)
	print("Called OneSignal.EnableSound")
end

OneSignalObject.EnableNotificationsWhenActive = function(enable)
   print("Called OneSignal.EnableNotificationsWhenActive")
end

OneSignalObject.EnableInAppAlertNotification = function(enable)
   print("Called OneSignal.EnableInAppAlertNotification")
end

OneSignalObject.SetSubscription = function(enable)
   print("Called OneSignal.SetSubscription")
end

OneSignalObject.PostNotification = function(data, onSuccessCallback, onFailureCallback)
   print("Called OneSignal.PostNotification")
end

OneSignalObject.SetEmail = function (email)
	print("Called OneSignal.SetEmail")
end

OneSignalObject.PromptLocation = function ()
	print("Called OneSignal.PromptLocation")
end

OneSignalObject.SetLogLevel = function(logLevel, visualLevel)
	print("Called OneSignal.SetLogLevel")
end

OneSignalObject.AddTrigger = function(key, value)
	print("Called OneSignal.AddTrigger")
end

OneSignalObject.AddTriggers = function(triggers)
	print("Called OneSignal.AddTriggers")
end

OneSignalObject.RemoveTriggerForKey = function(key)
	print("Called OneSignal.RemoveTriggerForKey")
end

OneSignalObject.RemoveTriggersForKeys = function(keys)
	print("Called OneSignal.RemoveTriggersForKeys")
end

OneSignalObject.GetTriggerValueForKey = function(key)
	print("Called OneSignal.GetTriggerValueForKey")
end

OneSignalObject.PauseInAppMessages = function(pause)
	print("Called OneSignal.PauseInAppMessages")
end


-------------------------------------------------------------------------------
-- END
-------------------------------------------------------------------------------

-- Return an instance
return OneSignalObject
