This is a proof-of-concept project that builds a BuunyNet middleware plugin for Munki 7.

It is a port of ofirgalcon's bunny.net-middleware:  
https://github.com/ofirgalcon/bunny.net-middleware

It differs from the original in that the security key is stored as
"BunnyNetKey" in the "ManagedInstalls" preferences domain. (ofirgalcon's Python version stored it as "bunny_key" in a specific plist: `/private/var/root/Library/Preferences/ManagedInstallsProc`)

Though some unit testing was done to confirm that given the same inputs, the Swift implementation generates the same outputs as the Python implementation, as of May 15, 2025, this has not actually been tested against a repo hosted on BunnyNet. If you test it and it works, please let me know!

The middleware plugin must be installed in /usr/local/munki/middleware/, and you need Munki 7.0.0.5139 or later to test.

To build the middleware plugin and an Installer pkg that installs it, cd into this directory and run `./build_pkg.sh`. You will need a recent version of Xcode.