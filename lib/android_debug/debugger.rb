require 'java'
java_import 'com.sun.jdi.request.EventRequest'
java_import 'java.util.ArrayList'

module AndroidDebug
    # This is the main interaction point for the user
    class Debugger
        INVOKE_SINGLE_THREADED = 1

        attr_accessor :android_home, :on_break

        # Private virtual machine object
        attr_reader :vm

        # Private VM manager object
        attr_reader :mgr

        # Private ADB object
        attr_reader :adb

        # Private array of entry brakepoints
        attr_reader :class_entry_breakpoints

        # Private array of exit  brakepoints
        attr_reader :class_exit_breakpoints

        # "this" object of the current breakpoint. Or, the current instance of the object that the breakpoint was set in.
        attr_reader :this

        # The current [AndroidDebug::Jpda::Frame] object. Methods and instance variables.
        attr_reader :frame

        # Constructor
        # @param android_home [String] the SDK location
        def initialize(android_home = AndroidDebug::Adb.get_android_home)
            @android_home = android_home

            @class_entry_breakpoints = {}
            @class_exit_breakpoints = {}
            @method_breakpoints = {}
            
            $CLASSPATH << "#{@android_home}/tools/lib/ddmlib.jar"
            java_import 'com.android.ddmlib.AndroidDebugBridge'
            
            @adb = AndroidDebug::Adb.init_adb
        end

        # Connect the android debugger to a remote host/port
        # @param host 
        # @param port 
        def connect_host_port(host, port)
            $DEBUG and puts("Connecting to debugger on #{host}:#{port}")
            conn, args = AndroidDebug::Jpda.get_socket_connector_and_args(host, port)
            $DEBUG and puts("Connected. Attaching to Java VM.")
            @vm = conn.attach(args)
            @mgr = @vm.eventRequestManager
            $DEBUG and puts("Attached.")
        end

        # Helper to connect to a localhost port
        # @param port
        def connect_port(port)
            connect_host_port("localhost", port)
        end

        # Helper method to connect to whatever port is listening for a debugger
        def connect
            begin
                port = get_debugger_port
            rescue
                # Sometimes this will fail if we don't wait long enough, try one more time
                sleep(2)
                port = get_debugger_port
            end
            connect_host_port("localhost", port)
        end

        # Communication with the Android debugger is performed over an open localhost
        # port. This helper function utilizes the Android DDMS libraries to determine
        # what ports are currently open and waiting for a debugger.
        # @return the local port that is listening for a debugger
        def get_debugger_port
            throw "Could not get devices from adb" if @adb.getDevices.size == 0
            dev = @adb.getDevices[0]
            sleep(1)
            throw "Could not get clients for device (#{dev})" if dev.getClients.size == 0
            dev.getClients.each do |cli|
                $DEBUG and puts("Found process: #{cli}")
                if(cli.getClientData.getDebuggerConnectionStatus.to_s == "WAITING")
                    $DEBUG and puts("Found process waiting for debugger: #{cli} : #{cli.getDebuggerListenPort}")
                    return(cli.getDebuggerListenPort)
                end
            end
            throw("Could not find a process waiting for debugger.")
            return(nil)
        end

        # Disconnect the debugger
        def disconnect
            #@vm.exit(0)
            AndroidDebug::Adb.cleanup_adb
        end

        # Main loop of the library. This will launch the application, wait for
        # breakpoints and process them accordingly.
        def go
            while(true)
                process_event(wait_for_event)
            end
        end

        # Private method that will process an event when it comes in. On Breakpoint
        # events, it will call on_break, which is the user supplied method.
        def process_event(event)
            if(event.type == AndroidDebug::Jpda::Event::ENTRY or
                event.type == AndroidDebug::Jpda::Event::EXIT)
                on_break(event)
            elsif(event.type == AndroidDebug::Jpda::Event::VM_EXIT)
                puts("The VM was disconnected.")
                exit(0)
            else
                $DEBUG and puts("Received unknown event type: #{event}")
            end
        end

        # Private method that will wait for an incoming event and return it. This 
        # exists because different portions of the library need to retrieve events
        # such as a Breakpoint event is handled differently than a Step event.
        # @return [AndroidDebug::Jpda::Event]
        def wait_for_event
            q = @vm.eventQueue()
            while(true)
                event_set = q.remove()
                it = event_set.iterator()
                while(it.hasNext)
                    event = it.next
                    $DEBUG and puts("Received an event: #{event.java_class}")
                    @frame = AndroidDebug::Jpda::Frame.new(event.thread.frame(0), event.location)
                    @this = @frame.this
                    return(AndroidDebug::Jpda::Event.new(event))
                end                
            end
        end

        # Private helper method that will process events until a step event occurs.
        # It will also process all breakpoint events as they occur. There may be an
        # occasion where a step will run into a break.
        def wait_for_step_event
            while(true)
                event = wait_for_event
                if(event.java_event.java_kind_of?(com.sun.jdi.event.StepEvent))
                    return
                else
                    process_event(event)
                end
            end
        end

        # Add a breakpoint for when application control flow enters a class.
        # @param class_filter [String] that represents a regular expression of where to
        # break.
        # Example:
        # => "android.content.Context"
        # => "android.content.*"
        def add_class_entry_breakpoint(class_filter)
            return if @class_entry_breakpoints[class_filter]

            bp = @mgr.createMethodEntryRequest
            bp.setSuspendPolicy(EventRequest.SUSPEND_ALL);
            bp.addClassFilter(class_filter);
            bp.enable();

            @class_entry_breakpoints[class_filter] = bp
        end

        # Add a breakpoint that will only trigger once.
        # @param class_filter [String] see #{AndroidDebug::Debugger::add_class_entry_breakpoint}
        def add_temporary_class_entry_breakpoint(class_filter)
            bp = @mgr.createMethodEntryRequest
            bp.setSuspendPolicy(EventRequest.SUSPEND_ALL)
            bp.addClassFilter(class_filter)
            bp.addCountFilter(1)
            bp.enable()
        end

        # Add a breakpoint for when application control flow exits a class.
        # Sometimes, the local variables of the [AndroidDebug::Jpda::Frame] object
        # will contain the return value.
        # Android does not support the JPDA method to get the return value of a method.
        # @param class_filter [String] see #{AndroidDebug::Debugger::add_class_entry_breakpoint}
        def add_class_exit_breakpoint(class_filter)
            return if @class_exit_breakpoints[class_filter]

            bp = @mgr.createMethodExitRequest
            bp.setSuspendPolicy(EventRequest.SUSPEND_ALL)
            bp.addClassFilter(class_filter)
            bp.enable()

            @class_exit_breakpoints[class_filter] = bp
        end

        # Add a breakpoint that will only trigger once.
        # @param class_filter [String] see #{AndroidDebug::Debugger::add_class_entry_breakpoint}
        def add_temporary_class_exit_breakpoint(class_filter)
            bp = @mgr.createMethodExitRequest
            bp.setSuspendPolicy(EventRequest.SUSPEND_ALL)
            bp.addClassFilter(class_filter)
            bp.addCountFilter(1)
            bp.enable()
        end

        # Remove an entry breakpoint that was already created
        # @param class_filter [String] see #{AndroidDebug::Debugger::add_class_entry_breakpoint}
        def remove_class_entry_breakpoint(class_filter)
            @mgr.deleteEventRequest(@class_entry_breakpoints.delete(class_filter))
        end

        # Remove an exit breakpoint that was already created
        # @param class_filter [String] see #{AndroidDebug::Debugger::add_class_entry_breakpoint}
        def remove_class_exit_breakpoint(class_filter)
            @mgr.deleteEventRequest(@class_exit_breakpoints.delete(class_filter))
        end

        # The code block that will process breakpoints. It will pass the 
        # [AndroidDebug::Jpda::Event] object
        # @param block is the block
        # Example:
        # => dbg.on_break |event| do
        # =>     puts "Local variables:"
        # =>     puts dbg.frame.variables
        # => end
        def on_break(*args, &block)
            if block_given?
                @on_break = block
            else
                @on_break.call(*args) if @on_break
            end
        end

        # Must be called after a breakpoint. Will resume application flow.
        def resume
            @vm.resume
        end

        def step_over
            step_request = get_step_request(@frame.thread, com.sun.jdi.request.StepRequest.STEP_LINE, com.sun.jdi.request.StepRequest.STEP_OVER)
            step_request.enable
            @vm.resume
            wait_for_step_event
            @mgr.deleteEventRequest(step_request)
        end

        def step_into
            step_request = get_step_request(@frame.thread, com.sun.jdi.request.StepRequest.STEP_MIN, com.sun.jdi.request.StepRequest.STEP_INTO)
            step_request.enable()
            @vm.resume
            wait_for_step_event
            @mgr.deleteEventRequest(step_request)
        end

        def step_out
            step_request = get_step_request(@frame.thread, com.sun.jdi.request.StepRequest.STEP_LINE, com.sun.jdi.request.StepRequest.STEP_OUT)
            step_request.enable()
            @vm.resume
            wait_for_step_event
            @mgr.deleteEventRequest(step_request)
        end

        
        # There is only one StepRequest per thread. If the thread contains one, return it, else create.
        def get_step_request(thread, size, depth, count_filter=1)
=begin
            @mgr.stepRequests.each do |step_request|
                if(step_request.thread == thread)
                    # TODO: Need to figure out how to modify the step request

                    # attempt to delete the request, but it may be the one we are currently broke on
                    #begin
                        #@mgr.deleteEventRequest(step_request)

                    #rescue java.util.ConcurrentModificationException => e
                        # Couldnt delete it, so return it
                        return(step_request)
                    #end
                end
            end
=end
            step_request = @mgr.createStepRequest(thread, size, depth)  # Will thorw java.util.ConcurrentModificationException if attempted after a delete
            step_request.addCountFilter(count_filter)
            return(step_request)
        end

        # @return An array of frames [com.sun.jdi.StackFrame]
        def backtrace
            return(@frame.thread.frames)
        end

        # Prints the backtrace
        def print_backtrace
            self.get_backtrace.each do |f|
                puts(f)
            end
        end

        # Finds the proper method object when you want to call a specific method on a
        # variable from within the current frame.
        # @param clazz [String] The class name you are looking for (may be the full
        # classpath or just the name)
        # @param method [String] The method name to be returned
        # @return An array of [com.sun.jdi.Method] {http://docs.oracle.com/javase/6/docs/jdk/api/jpda/jdi/com/sun/jdi/Method.html}
        def find_methods(clazz, method)
            ret = []

            classes = @vm.allClasses
            classes.each do |c|
                if(c.name == clazz or c.name.end_with?(clazz))
                    c.allMethods.each do |m|
                        if(m.name == method)
                            ret.push(m)
                        end
                    end
                end
            end
            return(ret)
        end


    end
end