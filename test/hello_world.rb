require_relative '../lib/android_debug.rb'

$DEBUG = true

dbg = AndroidDebug.launch_and_attach("com.wuntee.dummyandroidproject", "com.wuntee.dummyandroidproject.DummyAndroidProjectActivity")
#dbg = AndroidDebug.launch_and_attach("com.wuntee.dummyandroidproject", "com.wuntee.dummyandroidproject.DummyAndroidActivity")
dbg.on_break do

    puts("Frame variables:")
    dbg.frame.variables.each do |var|
        puts("\t#{var}")
        #if(var.name == "test2")
        #    dbg.frame.set_variable_by_name("test2", "changin variable")
        #end
    end
    puts("This object:")
    puts(dbg.this.inspect)
    if(dbg.this.method_names.index("log_int"))
        puts("CALLING LOG_NOARG")
        dbg.this.log_int(1234)
    end

    #if(event.method == "log")
    #    puts("Attempting to set log variable")
    #    dbg.set_variable_value(dbg.current_variables[0], "i changed the value via the debugger")
    #end
    dbg.resume
end
dbg.add_class_entry_breakpoint("com.wuntee.*")
dbg.go
