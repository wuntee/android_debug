module AndroidDebug
    module Mixin
        module Invokable
            # This is a mixin that provides the ability to invoke methods from objects. The
            # object must be of a type that has the 'invokeMethod' method. To specify the 
            # object which the invoking will be performed, you just set the @java_invokable_object
            # to the specific object.

            attr_reader :java_invokable_object, :java_frame

            # Invoke a method on the @java_invokable_object.
            # @param method either a [String] or a [com.sun.jdi.Method] {http://docs.oracle.com/javase/6/docs/jdk/api/jpda/jdi/com/sun/jdi/Method.html}
            # @param args [Array] of basic types that will be the argumets of the method being called
            def invoke_method(method, args={})
                $DEBUG and puts("Invoking method #{method} with args: #{args}")
                if(@java_frame.nil?)
                    throw("The current event does not have an associated thread, cant invoke a method.")
                end

                java_args = ArrayList.new
                args.each do |a|
                    java_args.add(@java_frame.virtualMachine.mirrorOf(a))
                end

                if(method.is_a?(String))
                    method = get_method(method)
                end


                $DEBUG and puts("Calling method #{method}")
                $DEBUG and puts("Thread: #{@java_frame.thread}")
                $DEBUG and puts("Method: #{method}")
                $DEBUG and puts("Args: #{java_args}")
                @java_invokable_object.invokeMethod(@java_frame.thread, method, java_args, com.sun.jdi.ObjectReference.INVOKE_SINGLE_THREADED) 
            end


            
            # @return An array of methods {http://docs.oracle.com/javase/6/docs/jdk/api/jpda/jdi/com/sun/jdi/Method.html}
            def methods
                # In java, primitive values dont have methods, this ensures we can call 'referenceType'
                !@java_invokable_object.java_kind_of?(com.sun.jdi.ObjectReference) and return([])

                # This happens for certain unknown LocalVariable object types
                @java_invokable_object.nil? and return([])

                return(@java_invokable_object.referenceType.methods)
            end

            # @return An array of method names as strings
            def method_names
                ret = []
                methods.each do |m|
                    ret.push(m.name)
                end
                return(ret)
            end

            # @param name [String] of the method you are looking to find
            # @param index of the name, default 0. This takes care of when Java has overloaded methods. They will all have the same name.
            # @return A java Method object for a specific method of the @java_invokable_object
            def get_method(name, index=0)
                ret = []
                methods.each do |m|
                    if(m.name == name)
                        ret.push(m)
                    end
                end
                return(ret[index])
            end

            # Handler when attempting to call a method of an object that has this mixin. It will attempt to call the Java method of that object.
            # For example, if you have some ObjectReference of a Java String. You can directly call ObjectReference.toString() and it will pass 
            # through to attempt to call that native Java method.
            def method_missing(m, *args, &block)
                # Attempt to call a method on the object directly
                if(method_names.index(m.to_s))
                    $DEBUG and puts("Attempting to invoke_method '#{m}'")
                    invoke_method(get_method(m.to_s), args)
                else
                    super.method_missing(m, *args, &block)
                end
            end

            # @return A detailed string representation of the object
            def inspect
                puts(@java_invokable_object.to_s)
                puts("\tMethods:")
                methods.each do |m|
                    puts("\t\t#{m.to_s}")
                end
            end
        end
    end
end