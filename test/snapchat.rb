require 'android_debug'
dbg = AndroidDebug.launch_and_attach("com.snapchat.android", "com.snapchat.android.LandingPageActivity")
dbg.on_break do 
'''
    if(dbg.frame.method_name == "doFinanl")
        puts("#{dbg.frame.method_signature}")
        puts("Frame variables:")
        dbg.frame.variables.each do |var|
            puts("\t#{var}")
        end
    end
'''
	puts(dbg.frame.method_name)
    dbg.resume
end
dbg.add_class_entry_breakpoint("javax.crypto.Cipher")
dbg.go
