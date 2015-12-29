require 'open-uri'
require_relative 'spec_helpers.rb'
require_relative '../stack_builder.rb'

include SpecHelpers

describe StackBuilder do

	# Create the stack builder
	before :all do
		@stack_builder = StackBuilder.new({ credentials_filename: '../credentials.json',
																				config_filename: 'test_configuration.json' })
		puts "Running StackBuilder test suite.\nNote that a stack will be built before tests are run,"\
	  " and deleted once they are finished."
	end

	# Delete the stack
	after :all do
		puts "\nTests finished.. Deleting stack"
		@stack_builder.delete_stack
	end

	it "tests that a stack is built" do
		puts "Stack creation started"
		expect(@stack_builder).to respond_to(:build_stack)
		expect(@stack_builder.build_stack).to be true
	end

	it "tests that the servers SSH and HTTP ports are reachable" do
		ip = format_output_ip(@stack_builder.print_stack_output)
		puts "\nWaiting for SSH port to come online.."
		poll_port(ip, 22, "SSH", 5)
		expect(open_port?(ip, 22)).to be true
		puts "Waiting for HTTP port to come online.."
		poll_port(ip, 80, "HTTP", 5)
		expect(open_port?(ip, 80)).to be true
	end

	it "tests that the web application has the correct content" do
		test_string = "Automation for the People"
		file = open(@stack_builder.print_stack_output)
		contents = file.read
		expect(contents).to include(test_string)
		puts "\nContent string, \"#{test_string}\" matched on web application"
	end

end
