#!/bin/bash

function msg {
	printf "\e[1;32m>\e[m %s\n" "$1"
}
function msg2 {
	printf "\e[1;34m>\e[m %s\n" "$1"
}

msg "reset Sibelius Ultimate!"

sudo rm -Rf /Applications/APi1

sudo rm -Rf /Library/Application\ Support/Avid/Sibelius/_manuscript/ACr2

sudo rm -Rf /Library/Application\ Support/Avid/Sibelius/_manuscript/Plugins_v2

sudo rm -Rf ~/Library/Application\ Support/Avid/Sibelius/_manuscript/HEa3



msg "Completed!"

osascript <<EOT
tell application "Finder"
 activate
 display alert "Done!..."
end tell
EOT

