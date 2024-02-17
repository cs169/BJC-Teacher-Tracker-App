# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  #do not change this: my email is registered with the API key
  BJC_CONTACT = "BJC <arushc@berkeley.edu>"
  default from: BJC_CONTACT, reply_to: BJC_CONTACT
  layout "mailer"
end
