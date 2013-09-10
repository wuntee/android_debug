require 'optparse'
require_relative '../lib/android_debug.rb'


options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: print _variables.rb [options]"
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
    opts.on("-m", "--method STR", "Method that you would like to print variables from (optional). Use '<init>' for constructor.") do |m|
        options[:method] = m
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
    if(options[:method].nil? or (dbg.frame.method_name == options[:method]))
        puts(dbg.frame.method_signature)
        dbg.frame.variables.each do |var|
            puts("\t#{var}")
        end
        puts
    end
    dbg.resume
end
dbg.go
