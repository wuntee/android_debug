require_relative '../lib/android_debug.rb'

$DEBUG = true 

dbg = AndroidDebug.launch_and_attach_native("com.android.browser", "com.android.browser.BrowserActivity")

# Set the breakpoint method
dbg.add_class_entry_breakpoint("android.content.Intent")

# Find the variable you want to call the method on
dbg.on_break do |event|

    # If were in the correct method
    if(dbg.frame.method_name == "getParcelableExtra")
        puts(dbg.frame.method_signature)

=begin        
        # Find the variable
        dbg.frame.variables.each do |var|

            # Make sure its the variable we want to change
            if(var.name = "name")

                # Change the value
                dbg.frame.set_variable(var, "networkInfo1")
            end
        end
=end

        # Or we can just use the helper method
        dbg.frame.set_variable_by_name("name", "networkInfo1")

        puts
    end
    dbg.resume
end
dbg.go
