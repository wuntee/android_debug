require 'java'
java_import "com.sun.jdi.Bootstrap"

module AndroidDebug
    module Jpda
        CONNECTOR_PROCESS = "com.sun.jdi.ProcessAttach"
        CONNECTOR_SOCKET = "com.sun.jdi.SocketAttach"
        CONNECTOR_COMMAND_LINE = "com.sun.jdi.CommandLineLaunch"

        # Static method to get a 'connector' object which allows you to connect to a remote Java debugging process
        # @return [com.sun.jdi.connect.Connector] {http://docs.oracle.com/javase/6/docs/jdk/api/jpda/jdi/com/sun/jdi/connect/Connector.html}
        def self.get_connector(name)
            connectors = Bootstrap.virtualMachineManager().allConnectors()
            connectors.each do |c|
                if(c.name == name)
                    return(c)
                end
            end
        end

        # @return A fully configured [com.sun.jdi.connect.AttachingConnector] {http://docs.oracle.com/javase/6/docs/jdk/api/jpda/jdi/com/sun/jdi/connect/AttachingConnector.html}
        def self.get_socket_connector_and_args(host, port)
            ret = self.get_connector(CONNECTOR_SOCKET)
            arg = ret.defaultArguments()
            arg.get("hostname").setValue(host)
            arg.get("port").setValue(port)
            return([ret, arg])
        end


    end
end