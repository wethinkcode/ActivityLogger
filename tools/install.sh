
# Test Settings
# launchdPath=./LaunchAgents
# mkdir -p $launchdPath
# installPath=./MonitorLizard


# Settings
appName=MonitorLizard
appLabel=wtc.$appName.app

tempInstallPath=$HOME/tempInstallFiles
gitBinPath=$tempInstallPath/Build/Products/Release/ActivityLogger

launchdPath=$HOME/Library/LaunchAgents
installPath=$HOME/Library/MonitorLizard

PORT=19000
HOST=endpoint.wethinkcode.co.za

# PORT=4000
# HOST=10.212.6.4

# Create Install Path
mkdir -p $installPath 

# Clone repo, copy bin, delete
rm -rf ./tempInstallFiles
env git clone https://github.com/WSeegers/MacLogger.git ./tempInstallFiles
mv ./tempInstallFiles/Build/Products/Release/ActivityLogger $installPath/$appName
rm -rf ./tempInstallFiles

# Make Plist
cat <<EOF >$launchdPath/$appLabel.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>

    <key>Label</key>
    <string>$appLabel</string>

    <key>RunAtLoad</key>
    <true/>

	<key>KeepAlive</key>
	<true/>

    <key>EnvironmentVariables</key>
    <dict>
        <key>PORT</key>
        <string>$PORT</string>
        <key>HOST</key>
        <string>$HOST</string>
    </dict>

    <key>StandardOutPath</key>
	<string>$installPath/logfile.log</string>

	<key>StandardErrorPath</key>
	<string>$installPath/error.log</string>

    <key>WorkingDirectory</key>
    <string>$installPath</string>

    <key>ProgramArguments</key>
    <array>
        <string>$installPath/$appName</string>
    </array>

  </dict>
</plist>
EOF

# Load Deamon
launchctl unload $launchdPath/$appLabel.plist
launchctl load $launchdPath/$appLabel.plist

# Create Disable Script
cat <<EOF >$installPath/enable.sh
	launchctl -w load $launchdPath/$appLabel.plist
EOF

cat <<EOF >$installPath/disable.sh
	launchctl -w unload $launchdPath/$appLabel.plist
EOF
