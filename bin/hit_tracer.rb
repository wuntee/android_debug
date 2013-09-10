require 'optparse'
require 'pp'
require_relative '../lib/android_debug.rb'


options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: hit_tracer.rb [options]"
    opts.on("-d", '--debug', "Enable debug logging.") do |v|
        $DEBUG = true
    end
    opts.on("-l", "--launch STR", "Launch an application. Ex: com.android.browser/com.android.browser.BrowserActivity") do |l|
        split = l.split("\/")
        options[:app_class] = split[0]
        options[:app_pkg] = split[1]
    end
    opts.on("-c", "--class STR", "Regular expression for classes to track.") do |c|
        options[:class_regex] = c
    end
end.parse!
raise OptionParser::MissingArgument if 
    options[:app_class].nil? or 
    options[:app_pkg].nil? or 
    options[:class_regex].nil? 

dbg = AndroidDebug.launch_and_attach(options[:app_class], options[:app_pkg])
dbg.add_class_entry_breakpoint(options[:class_regex])
vars = {}
dbg.on_break do |event|
    breakpoint = dbg.frame.method_signature
    vars[breakpoint].nil? ? (vars[breakpoint]=1) : 
        (vars[breakpoint]=vars[breakpoint]+1)
    puts("Hits:")
    pp(vars)
    puts
    dbg.resume
end
dbg.go
