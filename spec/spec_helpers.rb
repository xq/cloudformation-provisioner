require 'timeout'
require 'socket'

module SpecHelpers

	# Strips the http out of a link containing a server ip address
	def format_output_ip(ip_string)
		ip_string.gsub("http://","")
	end

	# Check if specified port on specified ip address is open
	def open_port?(ip, port)
		begin
			Timeout::timeout(1) do
				begin
					socket = TCPSocket.new(ip, port)
					socket.close
					return true
				rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
					return false
				end
			end
		rescue Timeout::Error
			return false
		end
	end

	# Polls a port on a specified ip address until it is found
	# to be open or max tries is reached
	def poll_port(ip, port, port_type, timer, max_tries = 10)
		while(open_port?(ip, port) != true) do
			puts "#{port_type} port not online yet.."
			if max_tries == 0
				puts "Max port checks attempts reached"
				return
			else
				max_tries -= 1
			end
			puts "Checking again to see if #{port_type} port is up"
			sleep(timer)
		end
		puts "#{port_type} port online\n"
	end

end
