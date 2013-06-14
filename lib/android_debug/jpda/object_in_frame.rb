module AndroidDebug
    module Jpda
        class ObjectInFrame 
            include AndroidDebug::Mixin::JavaPassthrough
            include AndroidDebug::Mixin::Invokable

            attr_reader :java_object_reference
            attr_reader :java_frame # Defined in Invokable
            attr_reader :java_invokable_object # Defined in Invokable

            # Constructor
            # @param frame [com.sun.jdi.StackFrame] {http://docs.oracle.com/javase/6/docs/jdk/api/jpda/jdi/com/sun/jdi/StackFrame.html}
            # @param object_reference [com.sun.jdi.ObjectReference] {http://docs.oracle.com/javase/6/docs/jdk/api/jpda/jdi/com/sun/jdi/ObjectReference.html}
            def initialize(frame, object_reference)
                @java_frame = frame
                @java_object = @java_invokable_object = @java_object_reference = object_reference
            end

            # @return A string representation of the object
            def to_s
                return(@java_object_reference.to_s)
            end

            # @return A string representation of the object's class name
            def class_name
                return(@java_object_reference.to_s)
            end

            # @return A string representation of the unique ID of the object
            def id
                return(@java_object_reference.uniqueID)
            end

            # @param obj Object to compare, either [AndroidDebug::Jpda::ObjectInFrame] or [com.sun.jdi.ObjectReference]
            def ==(obj)
                obj.instance_of(AndroidDebug::Jpda::ObjectInFrame) and return(obj.java_object_reference.uniqueID == @java_object_reference.uniqueID)
                obj.java_kind_of?(com.sun.jdi.ObjectReference) and return(obj.uniqueID == @java_object_reference.uniqueID)
                return(false)
            end

        end

    end
end