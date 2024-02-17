# frozen_string_literal: true

class TeacherMailer < ApplicationMailer
  #change CONTACT_EMAIL to cc yourself on the emails that get sent out
  CONTACT_EMAIL = "Arush Chhatrapati <arushc@berkeley.edu>"
  BJC_EMAIL = "BJC <arushc@berkeley.edu>"

  before_action :email_template
  default content_type: "text/html",
          template_name: "main"

  def welcome_email(teacher)
    @teacher = teacher
    set_body
    mail to: teacher.email_name,
         cc: CONTACT_EMAIL,
         subject: email_template.subject
  end

  def deny_email(teacher, denial_reason)
    @teacher = teacher
    @denial_reason = denial_reason
    set_body
    mail to: @teacher.email_name,
         cc: CONTACT_EMAIL,
         subject: email_template.subject
  end

  def request_info_email(teacher, request_reason)
    @teacher = teacher
    @request_reason = request_reason
    set_body
    mail to: @teacher.email_name,
         cc: CONTACT_EMAIL,
         subject: email_template.subject
  end

  def form_submission(teacher)
    @teacher = teacher
    set_body
    if @teacher.not_reviewed?
      mail to: CONTACT_EMAIL,
           subject: email_template.subject
    end
  end

  private
  def liquid_assigns
    base_rules = {
      bjc_password: Rails.application.secrets[:bjc_password],
      piazza_password: Rails.application.secrets[:piazza_password],
      denial_reason: @denial_reason
    }
    base_rules.merge!(@teacher.email_attributes)
    base_rules.with_indifferent_access
  end

  def email_template
    @email_template ||= EmailTemplate.find_by(title: action_name.titlecase)
  end

  def set_body
    @body = Liquid::Template.parse(email_template.body).render(liquid_assigns).html_safe
  end
end
