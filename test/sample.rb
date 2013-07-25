require 'android_debug'
dbg = AndroidDebug.launch_and_attach("com.android.browser", "com.android.browser.BrowserActivity")
dbg.on_break do 
    if(dbg.frame.method_name == "registerReceiver")
        puts("#{dbg.frame.method_signature}")
        puts("Frame variables:")
        dbg.frame.variables.each do |var|
            puts("\t#{var}")
        end
    end
    dbg.resume
end
dbg.add_class_entry_breakpoint("android.content.Context")
dbg.go
