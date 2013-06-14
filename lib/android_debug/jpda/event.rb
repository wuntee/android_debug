module AndroidDebug
    module Jpda
        class Event
            include AndroidDebug::Mixin::JavaPassthrough
            
            ENTRY = "entry"
            EXIT = "exit"
            BREAKPOINT = "breakpoint"
            VM_EXIT = "vm_destry"
            UNKNOWN = "unknown"

            attr_reader :java_event

            # Constructor for the wrapper of com.sun.jdi.event
            # @param event [com.sun.jdi.event.Event] 
            def initialize(event)
                @java_object = @java_event = event
            end

            # @return [String] type of this event
            def type
                @java_event.java_kind_of?(com.sun.jdi.event.MethodEntryEvent) and return ENTRY
                @java_event.java_kind_of?(com.sun.jdi.event.MethodExitEvent) and return EXIT
                @java_event.java_kind_of?(com.sun.jdi.event.BreakpointEvent) and return BREAKPOINT
                @java_event.java_kind_of?(com.sun.jdi.event.VMDeathEvent) and return VM_EXIT
                @java_event.java_kind_of?(com.sun.jdi.event.VMDisconnectEvent) and return VM_EXIT
                return(UNKNOWN)
            end
        end
    end
end