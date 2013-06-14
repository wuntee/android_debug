require_relative '../lib/android_debug.rb'

$DEBUG = false

dbg = AndroidDebug.launch_and_attach("com.android.browser", "com.android.browser.BrowserActivity")
#dbg = AndroidDebug.launch_and_attach("com.wuntee.dummyandroidproject", "com.wuntee.dummyandroidproject.DummyAndroidActivity")

vars = {}

dbg.on_break do |event|
    !vars[dbg.this.to_s] and vars[dbg.this.to_s] = []
    vars[dbg.this.to_s].push("#{dbg.frame.method_name}(#{dbg.frame.variables.join(',')})")

    puts("New method called on object: #{dbg.this.to_s}")
    vars[dbg.this.to_s].each do |method|
        puts("\t#{method}")    
    end

    puts

    dbg.resume
end
dbg.add_class_entry_breakpoint("android.content.Intent")
#dbg.add_class_exit_breakpoint("android.content.Intent")
dbg.go
