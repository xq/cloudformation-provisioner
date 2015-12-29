# CloudFormation Provisioner

## Main Application

This repository contains the scripts necessary to provision a web application server
from scratch, using Amazon's CloudFormation service. Before you get started, make
sure the following prerequisities are satifised:

- ruby 2.0.0p645 or higher is installed on your system

- The following gems are installed and are up to date:

  aws-sdk-core

  aws-sdk-resources

- credentials.json has been obtained from HR and placed in the
  root directory of this project

- Once the above requirements have been satisfied, run the following
  command from the projects root directory:

  `ruby stack_builder_interface.rb`

The provisioner will then run, notifying when the stack has been created
and when the web application is up and running for you to view.

## Tests

The repository also contains a suite of tests to verify that the provisioner
works properly. To run them, make sure the following gem is installed and up to date:

- rspec

To run the tests, navigate to the projects root directory and enter the following:

  `cd spec`

  `rspec stack_builder_spec.rb`

The tests will then go through the process of provisioning a test stack,
verifying that it runs and is accessible, and finishes by deleting it.
