#!/usr/bin/ruby

require "net/http"
require './stack_builder.rb'

class StackBuilderInterface

	attr_accessor :stack_builder

	HTTP_OK_CODE = "200"

	def print_stack_result
		puts "Application online. You can access the application by visiting the following url:\n"
		puts "#{@stack_builder.print_stack_output}"
	end

	def check_application_status
		puts "Checking to see if web application is online.."
		url_string = @stack_builder.print_stack_output + "/"
		response = Net::HTTP.get_response(URI(url_string))
		if response.code != HTTP_OK_CODE
			poll_application_status
		end
	rescue Errno::ECONNREFUSED
		poll_application_status
	end

	def poll_application_status
		puts "Web application still initializing.. Waiting 5 seconds before checking again.." 
		sleep(5)
		check_application_status
	end

	def run
		@stack_builder = StackBuilder.new('serverTemplate.json')
		puts "Creating stack now.. Please wait up to 5 minutes for stack creation to complete\n"
		puts "Once the stack has been created, the web application will be checked to see if it is live\n"
		puts "Once it is live, the URL for the web application will be printed for you to access"
		@stack_builder.build_stack
		puts "Stack creation complete.. Its public IP is #{@stack_builder.print_stack_output.gsub("http://","")}\n"
		self.check_application_status
		self.print_stack_result
	end

end

StackBuilderInterface.new.run
