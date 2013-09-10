require_relative '../lib/android_debug.rb'

counter = 0

# Launch the activity and attach the debugger
dbg = AndroidDebug.launch_and_attach_native("com.android.browser", "com.android.browser.BrowserActivity")

# Set the breakpoint method
dbg.add_class_entry_breakpoint("android.content.Intent")

# Find the variable you want to call the method on
dbg.on_break do |event|

    # You can only call ONE method on a breakpoint (at the moment) 
    # because the method may cause a loop depending on the other 
    # breakpoints. The internal debugger state does not properly
    # handle updating the 'this' variable after calling 

    if(counter % 2 == 0)
        # Invoke a method by fidning it and calling 'invoke_method'
        this_method = dbg.this.get_method("toString")
        response = dbg.this.invoke_method(this_method)    
        puts("Invoke Method Response(explicit): #{response}")
    else
        # Invoke a method by just calling it on the 'this' object
        response = dbg.this.toString
        puts("Invoke Method Response(implicit): #{response}")
    end
    counter = counter + 1
    dbg.resume
end

# Start the process
dbg.go
