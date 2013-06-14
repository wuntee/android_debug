module AndroidDebug
    module Mixin
        module JavaPassthrough
            attr_reader :java_object

            # Most of the classes we implement are just Java class wrappers. This will attempt to call the local Java method of the object we are wrapping. For example, AndroidDebug::Jpda::Event wraps the com.sun.jdi.event.Event object. It is possible to call any method of that Java object, simply by using the dot notation. Event.requests()
            def method_missing(m, *args, &block)
                @java_object.nil? and throw("The @java_object is not set for this class")
                !@java_object.respond_to?(m) and throw("The Java object does not respond to methd '#{m}' (#{@java_object.class})")
                $DEBUG and puts("Calling java native method: #{m}(#{args})")
                @java_object.send(m, *args)
            end
        end
    end
end