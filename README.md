android_debug
=============

This is a scriptable debugger for Android applications. Sample usage:

    require 'android_debug'
    dbg = AndroidDebug.launch_and_attach("com.android.browser", "com.android.browser.BrowserActivity")
    dbg.on_break do |event|
        puts("Break type: #{event}")
        if(dbg.frame.method_name == "registerReceiver")
            puts("#{dbg.frame.method_signature}")
            puts("Frame variables:")
            dbg.frame.variables.each do |var|
                puts("\t#{var}")
            end
        end
    end
    dbg.add_class_entry_breakpoint("android.content.Context")
    dbg.go

Core concepts:
--------------

* Environmental or global vairable ANDROID_HOME must be set to your SDK home (ex: /Users/wuntee/android-sdk-macosx). This is because it uses the 'adb' binary to launch applications for the debugger, and utilizes some of the DDMS java libraries.
* On a breakpoint, you can access variables, methods, locations via the initial 'AndroidDebug::Debugger' object
* Create/Launch a debugger via AndroidDebug.launch_and_attach(classpath, classname)
* AndroidDebug::Debugger.this is the "this" object within the class you broken in.
* AndroidDebug::Debugger.frame is the stackframe on where the break occured and is a AndroidDebug::Jpda::Frame object. This class has a bunch of helper methods to get fun data.
* You can invoke remote methods by calling Object.method(args)
* Invoking methods will re-start the application, and you will lose your break.
* Most classes are extending existing Java classes. Any method you will typically call on a java class will percilate down to the core Java class, if it exists. (See the JavaPassthrough mixin for specifics)

Contributing to android_debug
=============================

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

Copyright
=========

Copyright (c) 2013 wuntee. See LICENSE.txt for
further details.

