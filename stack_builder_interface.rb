#!/usr/bin/ruby

require "net/http"
require './stack_builder.rb'

class StackBuilderInterface

	attr_accessor :stack_builder

	HTTP_OK_CODE = "200"
	TEMPLATE_FILENAME = 'serverTemplate.json'

	def initialize(settings)
		@stack_builder = StackBuilder.new(settings)
	end

	def print_stack_result
		puts "Application online. You can access the application by visiting the following url:\n"
		puts "#{@stack_builder.print_stack_output}/"
	end

	def application_online?(url)
		puts "Checking to see if web application is online.."
		url_string = "#{url}/"
		response = Net::HTTP.get_response(URI(url_string))
		if response.code != HTTP_OK_CODE
			poll_application_status(url)
		end
		true
	rescue Errno::ECONNREFUSED
		poll_application_status(url)
	end

	def poll_application_status(url)
		puts "Web application still initializing.. Waiting 5 seconds before checking again" 
		sleep(5)
		application_online?(url)
	end

	def run
		puts "Creating stack now.. Please wait up to 5 minutes for stack creation to complete\n"
		puts "Once the stack has been created, the web application will be checked to see if it is live\n"
		puts "Once it is live, the URL for the web application will be printed for you to access"
		@stack_builder.build_stack
		puts "Stack creation complete.. Its public IP is #{@stack_builder.print_stack_output.gsub("http://","")}\n"
		self.print_stack_result if self.application_online?(@stack_builder.print_stack_output)
	end

end

settings = { credentials_filename: 'credentials.json',
						 config_filename: 'configuration.json',
						 template_filename: 'serverTemplate.json' }
StackBuilderInterface.new(settings).run
