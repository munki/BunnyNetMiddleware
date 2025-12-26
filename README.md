This is a proof-of-concept project that builds a BuunyNet middleware plugin for Munki 7.

It is a port of ofirgalcon's bunny.net-middleware:  
https://github.com/ofirgalcon/bunny.net-middleware

It differs from the original in that the preferred location for the security key is under "BunnyNetKey" in the "ManagedInstalls" preferences domain. (ofirgalcon's Python version stored it as "bunny_key" in a specific plist: `/private/var/root/Library/Preferences/ManagedInstallsProc`. This should still work, but makes it impossible to use a configuration profile for this setting)

Some unit testing is in place to confirm that given the same inputs, the Swift implementation generates the same outputs as the Python implementation. A basic test against a repo hosted on BunnyNet was successful (thanks @natewalck).

The middleware plugin must be installed in `/usr/local/munki/middleware/`, and you need Munki 7.0.0.5152 or later to test.

You can find the installer pkg in https://github.com/munki/BunnyNetMiddleware/releases

If you prefer to build the middleware plugin and an Installer pkg that installs it, cd into this directory and run `./build_pkg.sh`. You will need a recent version of Xcode.
