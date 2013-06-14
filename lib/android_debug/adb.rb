module AndroidDebug
    # Helper static methods for interacting with ADB
    module Adb

        # Set an activity to wait for the debugger upon next launch
        # @param activity [String] 
        def self.set_activity_debug(activity)
            system("#{self.get_adb} shell am set-debug-app -w #{activity}")
        end

        # Launch a specific activity
        # @param activity [String]
        # @param clazz [String]
        # Example:
        #   # Launches browser
        #   dbg = AndroidDebug.launch_and_attach("com.android.browser", "com.android.browser.BrowserActivity")
        def self.launch_activity(activity, clazz)
            system("#{self.get_adb} shell am start #{activity}/#{clazz}")
        end

        # @return The location of the adb binary
        def self.get_adb
            android_home = self.get_android_home
            return("#{android_home}/platform-tools/adb")
        end

        # @return the location of the the android SDK home directory
        def self.get_android_home
            android_home = ENV['ANDROID_HOME'] || $ANDROID_HOME or throw "ANDROID_HOME is not set in env or as a global variable."
            return(android_home)
        end

        # This initializes the ADB bridge in order to enumerate applications, debug ports, etc.
        # @return An AndroidDebugBridge object 
        def self.init_adb
            AndroidDebugBridge.init(true)
            adb = AndroidDebugBridge.createBridge("#{self.get_android_home}/platform-tools/adb", true)
            sleep(0.1)
            return(adb)
        end

        # Destructor to clean up the ADB bridge. Should be called on exit.
        def self.cleanup_adb
            AndroidDebugBridge.disconnectBridge
            AndroidDebugBridge.terminate
        end 
    end
end
