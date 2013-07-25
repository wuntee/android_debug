module AndroidDebug
    # Native ADB implementation so we dont need the ANDROID_HOME
    class AdbNative
        require 'socket'

        attr_reader :soc
        
        def send_command(command, new_connection = true)
            host = "localhost"
            port = 5037
            @soc.nil? || @soc.closed? || new_connection and @soc = TCPSocket.open(host, port)
            begin
                @soc.print("%04x" % command.size)
                @soc.print(command)
                response = read_soc
                if(response.match(/OKAY\d{4}.+/))
                    return(response["OKAY0000".length, response.size])   
                else
                    return(response)
                end
            rescue Errno::EPIPE
                puts("Connection to the ADB has been torn down.")
            end
        end

        def read_soc
            return @soc.recvfrom(1024)[0].strip
        end

        def devices
            devices = send_command("host:devices")
            if(devices == "")
                return({})
            else
                # Converts an array to a hash
                return(Hash[*devices.split(/\t/)])
            end
        end

        def version
            return(send_command("host:version"))
        end

        def jdwp_pids(device)
            send_command("host:transport-#{device}")
            send_command("jdwp", false)
            
            # format [4-size][rest]
            size = @soc.recvfrom(4)[0].to_i(16)
            ret = @soc.recvfrom(size)[0].strip
            return(ret[4, ret.size].split("\n"))
        end

        def forward_jdwp(device, local_port, remote_pid)
            return send_command("host:forward:tcp:#{local_port};jdwp:#{remote_pid}")
        end

        def shell_command(command, transport = "any", new_connection = true)
            send_command("host:transport-#{transport}", new_connection)
            send_command("shell:#{command}", false)
            return(@soc.read.strip)
        end

        def launch_activity(activity, clazz)
            shell_command("am start #{activity}/#{clazz}")
        end

        def set_activity_debug(activity)
            shell_command("am set-debug-app -w #{activity}")
        end
    end
end

