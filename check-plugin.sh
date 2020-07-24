#!/bin/sh

VERSION="1.1"
PROGNAME=`basename $0`

# 1) metadata.json is filled out with the contact, url, pluginName, and publisherId fields
# 2) docs/ should only have 1 folder in there which is the name of the plugin and nothing else.
# 3) docs/pluginName/should have at least an index.markdown thats filled out
# 4) docs/pluginName/FUNCTION.markdown and docs/pluginName/PROPERTY.markdown shoud NOT exist
# 4) plugins should have one or more folders in there in the format of year.coronaVersion (eg. 2013.1234)
# 4.1) Within each folder there should be and "android", "iphone", and "iphone-sim" folder.  If the plugin is NOT wrapped by a provider then it should have something in "mac-sim" and "win32-sim" folders.
# 5) samples should contain a project that runs

check_string_replacements()
{
	RESULT=0

	FILENAME="$1"

	STRINGS='PUBLISHER_CONTACT
	PUBLISHER_URL
	PUBLISHER_URL
	plugin.PLUGIN_NAME
	"REVERSE_PUBLISHER_URL"'

	for S in $STRINGS
	do
		grep -wq "$S" $FILENAME
		if [ $? = 0 ]
		then
			echo "$PROGNAME: replace '$S' with appropriate value in '$FILENAME'"
			RESULT=1
		fi
	done

	return $RESULT
}

check_docs_dir()
{
	RESULT=0

	if [ ! -d docs ]
	then
		echo "$PROGNAME: missing 'docs' directory"
		RESULT=1
		return
	fi

	if [ ! -d "docs/$PLUGIN_NAME" ]
	then
		echo "$PROGNAME: missing 'docs/$PLUGIN_NAME'"
		RESULT=1
		return
	fi

	if [ ! -f "docs/$PLUGIN_NAME/index.markdown" ]
	then
		echo "$PROGNAME: missing 'docs/$PLUGIN_NAME/index.markdown'"
		RESULT=1
	else
		# Make sure they've replaced the placeholders in the docs
		grep -wq "PLUGIN_NAME" "docs/$PLUGIN_NAME/index.markdown"
		if [ $? = 0 ]
		then
			echo "$PROGNAME: edit 'docs/$PLUGIN_NAME/index.markdown' and replace 'PLUGIN_NAME'"
			RESULT=1
		fi

		# Check that there's an "__Availability__" in the docs and that
		# it mentions one or more of the available options
		grep -wq "__Availability__" "docs/$PLUGIN_NAME/index.markdown"
		if [ $? != 0 ]
		then
			echo "$PROGNAME: add '__Availability__' line to 'docs/$PLUGIN_NAME/index.markdown' (indicating Starter, Pro and/or Enterprise)"
			RESULT=1
		else
			grep -w "__Availability__" "docs/$PLUGIN_NAME/index.markdown" | egrep -wq "Starter|Pro|Enterprise"
			if [ $? != 0 ]
			then
				echo "$PROGNAME: amend '__Availability__' line in 'docs/$PLUGIN_NAME/index.markdown' to indicate Starter, Pro and/or Enterprise"
				RESULT=1
			fi
		fi
	fi

	# Make sure they've renamed the placeholder files in the docs directory
	if [ -f "docs/$PLUGIN_NAME/FUNCTION.markdown" ]
	then
		echo "$PROGNAME: replace 'docs/$PLUGIN_NAME/FUNCTION.markdown' with actual function documentation"
		RESULT=1
	fi

	if [ -f "docs/$PLUGIN_NAME/PROPERTY.markdown" ]
	then
		echo "$PROGNAME: replace 'docs/$PLUGIN_NAME/PROPERTY.markdown' with actual property documentation"
		RESULT=1
	fi

	if [ "$RESULT" = 0 ]
	then
		EXTRAS=`ls "docs" | grep -wiv "$PLUGIN_NAME"`

		if [ "$EXTRAS" != "" ]
		then
			echo "$PROGNAME: extra items in 'docs' directory:"
			echo "$EXTRAS" | pr -t -o8

			RESULT=1
		fi
	fi

	return $RESULT
}

check_plugins_dir()
{
	if [ ! -d "plugins" ]
	then
		echo "$PROGNAME: missing 'plugins' directory"
		return 1
	fi

	if [ -d "plugins/VERSION" ]
	then
		echo "$PROGNAME: rename 'plugins/VERSION' to 'plugins/{YEAR}.{BUILDNUM}'"
		return 1
	fi

	DIRS=`ls plugins`

	for D in $DIRS
	do
		########################################################################
		if [ ! -d plugins/$D/iphone ]
		then
			echo "$PROGNAME: missing plugin component 'iphone'"
		else
			# Get the architectures.
			ARCHS=$(lipo -info plugins/$D/iphone/*.a 2>/dev/null)

			VALID_ARCHS=0
			INVALID_ARCHS=0

			####################################################################
			# Look for VALID and INVALID architectures.

			echo $ARCHS | grep -wq "armv7"
			if [ $? = 0 ]
			then
				VALID_ARCHS=$(expr $VALID_ARCHS + 1)
			fi

			echo $ARCHS | grep -wq "arm64"
			if [ $? = 0 ]
			then
				VALID_ARCHS=$(expr $VALID_ARCHS + 1)
			fi

			echo $ARCHS | grep -wq "i386"
			if [ $? = 0 ]
			then
				INVALID_ARCHS=$(expr $INVALID_ARCHS + 1)
			fi

			echo $ARCHS | grep -wq "x86_64"
			if [ $? = 0 ]
			then
				INVALID_ARCHS=$(expr $INVALID_ARCHS + 1)
			fi
			####################################################################

			if [ $INVALID_ARCHS -gt 0 ]
			then
				echo "$PROGNAME: Invalid architectures found in plugin library:"
				lipo -info plugins/$D/iphone/*.a
				echo "$PROGNAME: armv7 and arm64 are the ONLY valid architecture to have for iphone."
				return 1
			fi

			if [ $VALID_ARCHS -eq 0 ]
			then
				echo "$PROGNAME: No valid architectures found in plugin library:"
				lipo -info plugins/$D/iphone/*.a
				echo "$PROGNAME: armv7 and arm64 are the ONLY valid architecture to have for iphone."
				return 1
			fi
		fi
		########################################################################
		if [ ! -d plugins/$D/iphone-sim ]
		then
			echo "$PROGNAME: missing plugin component 'iphone-sim'"
		else
			# Get the architectures.
			ARCHS=$(lipo -info plugins/$D/iphone-sim/*.a 2>/dev/null)

			VALID_ARCHS=0
			INVALID_ARCHS=0

			####################################################################
			# Look for VALID and INVALID architectures.

			echo $ARCHS | grep -wq "i386"
			if [ $? = 0 ]
			then
				VALID_ARCHS=$(expr $VALID_ARCHS + 1)
			fi

			echo $ARCHS | grep -wq "x86_64"
			if [ $? = 0 ]
			then
				VALID_ARCHS=$(expr $VALID_ARCHS + 1)
			fi

			echo $ARCHS | grep -wq "armv7"
			if [ $? = 0 ]
			then
				INVALID_ARCHS=$(expr $INVALID_ARCHS + 1)
			fi

			echo $ARCHS | grep -wq "arm64"
			if [ $? = 0 ]
			then
				INVALID_ARCHS=$(expr $INVALID_ARCHS + 1)
			fi
			####################################################################

			if [ $INVALID_ARCHS -gt 0 ]
			then
				echo "$PROGNAME: Invalid architectures found in plugin library:"
				lipo -info plugins/$D/iphone-sim/*.a
				echo "$PROGNAME: i386 and x86_64 are the ONLY valid architecture to have for iphone-sim."
				return 1
			fi

			if [ $VALID_ARCHS -eq 0 ]
			then
				echo "$PROGNAME: No valid architectures found in plugin library:"
				lipo -info plugins/$D/iphone-sim/*.a
				echo "$PROGNAME: i386 and x86_64 are the ONLY valid architecture to have for iphone-sim."
				return 1
			fi
		fi
		########################################################################
	done

	return 0
}

check_samples_dir()
{
	RESULT=0

	if [ ! -d "samples" ]
	then
		echo "$PROGNAME: missing 'samples' directory"
		RESULT=1
		return
	fi

	for F in main.lua config.lua build.settings
	do
		if [ ! -f samples/$F ]
		then
			echo "$PROGNAME: missing sample app component '$F'"
			RESULT=1
		fi
	done

	if [ "$RESULT" = 0 ]
	then
		check_string_replacements samples/build.settings
		check_string_replacements samples/main.lua
	fi

	return $RESULT
}

check_result()
{
	if [ "$1" != 0 -o "$2" != 0 ]
	then
		echo 1
	else
		echo 0
	fi
}

echo "Corona SDK Plugin Checker $VERSION"
echo

if [ "$1" = "" ]
then
	echo "Usage: $PROGNAME plugin-name"
	exit 1
fi

PLUGIN_NAME=`basename "$1"`
RESULT=0
OVERALL_RESULT=0

check_string_replacements "metadata.json"
OVERALL_RESULT=`check_result $OVERALL_RESULT $RESULT`
check_docs_dir
OVERALL_RESULT=`check_result $OVERALL_RESULT $RESULT`
check_plugins_dir
OVERALL_RESULT=`check_result $OVERALL_RESULT $RESULT`
check_samples_dir
OVERALL_RESULT=`check_result $OVERALL_RESULT $RESULT`

echo
if [ "$OVERALL_RESULT" = "0" ]
then
	echo "Plugin '$PLUGIN_NAME' passes all checks"
	exit 0
else
	echo "Plugin '$PLUGIN_NAME' fails some checks, please fix before submission"
	exit $OVERALL_RESULT
fi
