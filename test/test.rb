require_relative '../lib/android_debug.rb'

$DEBUG = true

dbg = AndroidDebug.launch_and_attach_native("com.android.browser", "com.android.browser.BrowserActivity")
#dbg = AndroidDebug.launch_and_attach("com.wuntee.dummyandroidproject", "com.wuntee.dummyandroidproject.DummyAndroidActivity")

vars = {}

dbg.on_break do |event|
    if(dbg.frame.variables.size >= 2)
        puts("Number of vars: #{dbg.frame.variables.size}")
        dbg.frame.variables.each_with_index do |var, i|
            puts("-var[#{i}] #{var}")
            if(var.get_method("toString"))
                begin
                    puts("--RESPONSE: #{var.invoke_method('toString')}")
                rescue Exception => e
                    puts("--Could not invoke: #{e} ")
                end
            end
        end
    end

=begin
        puts(var.java_value.class)
        var.java_value.methods.each do |method|
            if(method.to_s == "toString")
                args = ArrayList.new
                puts("- Value: #{var.java_value.class}")
                puts("- Thread: #{event.java_object.thread.class}")
                puts("- Method: #{method.class}")
                puts("- Args: #{args.class}")
                begin
                    ret = var.java_value.invokeMethod(event.java_object.thread, method, args, 2)
                    puts("------INVOKED:  #{var.java_variable}.toString() = #{ret}")
                rescue Exception => e
                    puts("- Could not invoke method: #{e}")
                end
            end
        end
    end
=end
    dbg.resume
end
dbg.add_class_entry_breakpoint("android.content.Intent")
dbg.go
