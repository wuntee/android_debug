require 'helper'
require_relative "../lib/android_debug/adb_native.rb"

class TestAdbNative < Test::Unit::TestCase
    adb = AndroidDebug::AdbNative.new

    devices = adb.devices
    puts("Devices: #{devices}")

    if(devices == "")
        puts("WARNING: Could not test AdbNative. No ADB attached.")
    else
        should "Properly run shell commands properly" do
            pwd = adb.shell("cd / && pwd")
            puts("pwd: #{pwd}")
            assert_equal(pwd, "/")
        end
    end
end