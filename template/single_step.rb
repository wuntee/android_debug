require_relative '../lib/android_debug.rb'

def print_variables(frame)
    frame.variables.each do |var|
        puts(var)
    end
end

counter = 0

dbg = AndroidDebug.launch_and_attach_native("com.android.browser", "com.android.browser.BrowserActivity")

# Set the breakpoint method
dbg.add_class_entry_breakpoint("android.content.Intent")

# Find the variable you want to call the method on
dbg.on_break do |event|
    puts("Counter: #{counter}")
    print_variables(dbg.frame)
    dbg.step_into
    print_variables(dbg.frame)
    dbg.step_into
    print_variables(dbg.frame)
    puts
    dbg.resume
    counter = counter + 1
end

dbg.go