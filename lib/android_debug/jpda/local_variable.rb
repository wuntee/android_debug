require 'java'

module AndroidDebug
    module Jpda
        class LocalVariable 
            include AndroidDebug::Mixin::JavaPassthrough
            include AndroidDebug::Mixin::Invokable

            attr_reader :java_frame # Defined in Invokable
            attr_reader :java_invokable_object # Defined in Invokable

            attr_accessor :name
            attr_reader :java_local_variable, :java_value, :value, :type

            # Constructor
            # @param local_variable [com.sun.jdi.LocalVariable] {http://docs.oracle.com/javase/6/docs/jdk/api/jpda/jdi/com/sun/jdi/LocalVariable.html}
            # @param value [com.sun.jdi.Value] {http://docs.oracle.com/javase/6/docs/jdk/api/jpda/jdi/com/sun/jdi/Value.html}
            # @param frame [com.sun.jdi.StackFrame] {http://docs.oracle.com/javase/6/docs/jdk/api/jpda/jdi/com/sun/jdi/StackFrame.html}
            def initialize(local_variable, value, frame)
                @java_frame = frame
                @java_object = @java_local_variable = local_variable
                @java_value = @java_invokable_object = value

                value.nil? ? @type = "UNKNOWN_TYPE" : @type = value.type.name
                local_variable.nil? ? @name = "UNKNOWN_NAME" : @name = local_variable.name


                #@value = @java_value.invokeMethod(1, 2, 3, 4)
                @value = @java_value.to_s
            end

            # @return A string representation of the object
            def to_s
                return("#{@type} #{@name} = #{@value}")
            end

            # @return A string representation of the object
            def to_str
                return("#{@type} #{@name} = #{@value}")
            end

            # @return A detailed string representation of the object
            def inspect
                print("#{@type} #{@name} = ")
                if(@java_value.java_kind_of?(com.sun.jdi.ArrayReference))
                    inspect_array_reference(@java_value)
                else
                    puts @value
                end
            end

            # @return A detailed string representation of an array reference            
            def inspect_array_reference(array_reference, tabs=1)
                puts("[")
                array_reference.getValues.each_with_index do |val, i|
                    if(val.java_kind_of?(com.sun.jdi.ArrayReference))
                        puts("[")
                        inspect_array_reference(val, tabs+1)
                    else
                        print("\t"*tabs)
                        puts(val)
                    end
                end
                puts("]")
            end

            # @param obj Object to compare, either [AndroidDebug::Jpda::LocalVariable] or [com.sun.jdi.LocalVariable]
            def ==(obj)
                obj.instance_of?(AndroidDebug::Jpda::LocalVariable) and return(@java_local_variable.equals(obj.java_local_variable))
                obj.java_kind_of?(com.sun.jdi.LocalVariable) and return(@java_local_variable.equals(obj))
                return(false)
            end
        end
    end
end