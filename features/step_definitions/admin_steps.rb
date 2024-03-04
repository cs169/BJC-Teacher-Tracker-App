# frozen_string_literal: true

require "cucumber/rspec/doubles"

LOGIN_SERVICE = {
  Google: :google_oauth2,
  Microsoft: :microsoft_graph,
  Snap: :discourse,
  Clever: :clever
}.with_indifferent_access

# Returns a OAuth2 token associated with email "testadminuser@berkeley.edu"
Given(/I have an admin email/) do
  OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
                                                                       provider: "google_oauth2",
                                                                       uid: "123545",
                                                                       info: {
                                                                         name: "Admin User",
                                                                         first_name: "Admin",
                                                                         last_name: "User",
                                                                         email: "testadminuser@berkeley.edu",
                                                                         school: "UC Berkeley",
                                                                       }
                                                                     })
end

# Returns a OAuth2 token associated with email "randomemail@gmail.com"
Given(/I have a non-admin, unregistered (.*) email/) do |login|
  service = LOGIN_SERVICE[login]
  OmniAuth.config.mock_auth[service] = OmniAuth::AuthHash.new({
                                                                provider: service,
                                                                uid: "123545",
                                                                info: {
                                                                  name: "Random User",
                                                                  first_name: "Random",
                                                                  last_name: "User",
                                                                  email: "randomemail@berkeley.edu",
                                                                  school: "UC Berkeley",
                                                                }
                                                              })
end

# A wrapper around the omniauth link.
Then(/I can log in with (.*)/) do |login|
  service = LOGIN_SERVICE[login]
  allow(Teacher).to receive(:validate_auth).and_return(true)
  Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[service]
  page.find("button", text: /.*Sign in with #{login}/).click()
end

Then(/I cannot log in with Google/) do
  OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials
  page.find("button", text: /.*Sign in with Google/).click()
end

Then(/I can send a deny email/) do
  last_email = ActionMailer::Base.deliveries.last
  last_email.to[0].should eq "testteacher@berkeley.edu"
  last_email.subject.should eq "Deny Email"
  last_email.body.encoded.should include "Denial Reason"
end

Then(/I can send a request info email/) do
  last_email = ActionMailer::Base.deliveries.last
  last_email.to[0].should eq "testteacher@berkeley.edu"
  last_email.subject.should eq "Request Info Email"
  last_email.body.encoded.should include "We kindly ask you to provide the following details to complete your application:"
end

Then(/I attach the csv "([^"]*)"$/) do |path|
  Capybara.ignore_hidden_elements = false
  attach_file("file", File.expand_path(path))
  Capybara.ignore_hidden_elements = true
end

Given(/I capture the email count/) do
  # Instance variable gets cleared after each scenario, but can share data across step definitions
  @initial_email_count = ActionMailer::Base.deliveries.count
end

Then(/no new emails should have been sent/) do
  expect(ActionMailer::Base.deliveries.count).to eq @initial_email_count
end
