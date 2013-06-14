require 'java'
require_relative 'android_debug/mixin/java_passthrough.rb'
require_relative 'android_debug/mixin/invokable.rb'
require_relative 'android_debug/jpda/jpda_helper.rb'
require_relative 'android_debug/jpda/local_variable.rb'
require_relative 'android_debug/jpda/object_in_frame.rb'
require_relative 'android_debug/jpda/event.rb'
require_relative 'android_debug/debugger.rb'
require_relative 'android_debug.rb'
require_relative 'android_debug/adb.rb'
require_relative 'android_debug/jpda/frame.rb'

module AndroidDebug

    # Static helper function to launch a specific activity, attach the debugger, 
    # and return the debugger object
    # @return [AndroidDebug::Debugger]
    def self.launch_and_attach(package, clazz)
        AndroidDebug::Adb.set_activity_debug(package)
        AndroidDebug::Adb.launch_activity(package, clazz)
        sleep(0.1)

        dbg = AndroidDebug::Debugger.new
        dbg.connect()

        return(dbg)
    end

end