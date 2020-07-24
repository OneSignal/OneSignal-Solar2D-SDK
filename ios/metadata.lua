local metadata =
{
	plugin =
	{
		format = 'staticLibrary',
		staticLibs = { 'plugin_OneSignal' },
		frameworks = { 'WebKit', 'UserNotifications' },
		frameworksOptional = {},
		delegates = {"OneSignalCoronaDelegate"}
	},
}

return metadata
