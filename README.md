> **Maintainer needed**  
> This middleware was ported from Python to Swift for Munki 7 by Greg Neagle. However, Greg does not actually use this middleware and is not particularly motivated to support it. If you or your organization rely on this middleware, please consider taking over the responsibility for maintaining it.

This is a project that builds a BuunyNet middleware plugin for Munki 7.

It is a port of ofirgalcon's bunny.net-middleware:  
https://github.com/ofirgalcon/bunny.net-middleware

This plugin requires Munki 7.0.0.5152 or later.

It differs from the original in that the preferred location for the security key is under "BunnyNetKey" in the "ManagedInstalls" preferences domain. (ofirgalcon's Python version stored it as "bunny_key" in a specific plist: `/private/var/root/Library/Preferences/ManagedInstallsProc`. This should still work, but makes it impossible to use a configuration profile for this setting)

Some unit testing is in place to confirm that given the same inputs, the Swift implementation generates the same outputs as the Python implementation. A basic test against a repo hosted on BunnyNet was successful (thanks @natewalck).

#### Configuration
Configuration is similar to that of the Python plugin:
- Set the Munki preference `SoftwareRepoURL` (or `PackageURL` if you only serve the pkgs directory on bunny) to your Bunny.net Distribution URL.
- Set Bunny.net Middleware preferences for your Url Token Authentication Key  
```sudo defaults write /Library/Preferences/ManagedInstalls BunnyNetKey "YOUR_BUNNY_KEY"```
- Run managedsoftwareupdate and verify that signed Bunny.net requests are being made.  
```sudo managedsoftwareupdate --checkonly -vvv```

If you use a munkiaccess.pem file, the preferred location of this file is `/usr/local/munki/middleware/munkiaccess.pem`, but the path `/usr/local/munki/munkiaccess.pem` (which is used by the Python implementation of this middleware) should work as well.

#### Installation
You may download an Installer package for the current release of the middleware plugin from the [Releases](https://github.com/munki/BunnyNetMiddleware/releases) section.

To build the middleware plugin and an Installer pkg that installs it, `git clone` this project, `cd` into the project directory, and run `./build_pkg.sh`. You will need a recent version of Xcode.


