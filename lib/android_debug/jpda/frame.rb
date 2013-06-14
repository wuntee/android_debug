module AndroidDebug
    module Jpda
        class Frame 
            include AndroidDebug::Mixin::JavaPassthrough

            attr_reader :java_frame, :java_location

            # Constructor
            # @param frame [com.sun.jdi.StackFrame]
            # @param location [com.sun.jdi.Location]
            def initialize(frame, location)
                @java_object = @java_frame = frame
                @java_location = location
            end

            # @return A string representation of the current frame's method name at the current frame
            def method_name
                return(@java_location.method.name)
            end

            # @return A string representation of the current frame's method signature
            def method_signature
                return(@java_location.method.to_s)
            end

            # @return A string representation of the return type for the current frame's method
            def method_return_type
                return(@java_location.method.returnTypeName)
            end

            # @return An array of [AndroidDebug::Jpda::LocalVariable] objects which represent the local variables in the current frame
            def variables
                ret = []
                @java_frame.getValues(@java_frame.visibleVariables).each do |local_variable, value|
                    ret.push(AndroidDebug::Jpda::LocalVariable.new(local_variable, value, @java_frame))
                end

                return(ret)            
            end

            # @return [AndroidDebug::Jpda::ObjectInFrame] which represents the "this" object at the current frame. 
            def this
                return(AndroidDebug::Jpda::ObjectInFrame.new(@java_frame, @java_frame.thisObject))
            end

            
            # @param variable [AndroidDebug::Jpda::Variable]
            # @param value Basic type or [com.sun.jdi.Value]
            def set_variable(variable, value)
                new_value = @java_frame.virtualMachine.mirrorOf(value)
                puts("Variable: #{variable.java_local_variable.class}")
                puts("Variable type: #{variable}")
                puts("New Value: #{new_value.class}")
                puts("New Value value: #{new_value.value}")

                '''
                For some reason in this call either variable.java_value or new_value are of the wrong type
                    TypeError: cannot convert instance of class org.jruby.java.proxies.ConcreteJavaProxy to interface com.sun.jdi.Field
                '''
                @java_frame.setValue(variable.java_local_variable.to_java, new_value.to_java)
            end            

            # Sets the value of a variable in the current frame
            # @param name [String] of the variable that will be modified
            # @param value basic type of the value of the variable you are changing
            def set_variable_by_name(name, value)
                new_value = @java_frame.virtualMachine.mirrorOf(value)
                variables.each do |var|
                    if(var.name == name)
                        set_variable(var, name)
                        return
                    end
                end
            end

            # Prints the variables that are in the current frame
            def print_variables
                variables.each do |var|
                    puts(var)
                end
            end

        end
    end
end