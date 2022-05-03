# frozen_string_literal: true

require "smarter_csv"

require "activerecord-import"

class TeachersController < ApplicationController
  before_action :sanitize_params, only: [:new, :create, :edit, :update]
  before_action :require_login, except: [:new, :create]
  before_action :require_admin, only: [:validate, :deny, :delete, :index, :show]
  before_action :require_edit_permission, only: [:edit, :update, :resend_welcome_email]

  rescue_from ActiveRecord::RecordNotUnique, with: :deny_access

  def index
    @all_teachers = Teacher.where(admin: false)
  end

  def resend_welcome_email
    load_teacher
    if @teacher.validated? || @is_admin
      TeacherMailer.welcome_email(@teacher).deliver_now
    end
  end

  def new
    @teacher = Teacher.new
    @school = School.new
    @readonly = false
  end

  def import
    csv_file = params[:file]
    teacher_hash_array = SmarterCSV.process(csv_file)
    school_column = [:name, :city, :state, :website, :grade_level, :school_type, :tags, :nces_id]
    teacher_value = [[]]
    teacher_column = [:first_name, :last_name, :education_level, :email, :more_info, :personal_website, :snap, :status, :school_id]
    success_teacher_count = 0
    failed_teacher_email_count = 0
    failed_teacher_noemail_count = 0
    update_teacher_count = 0
    failed_teacher_email = []
    new_school_count = 0

    teacher_hash_array.each do |row|
      if Teacher.find_by(email: row[:email]) || Teacher.find_by(snap: row[:snap])
        # make sure teacher doesn't already exist
        teacher_db = Teacher.find_by(email: row[:email]) || Teacher.find_by(snap: row[:snap])

        if !row[:school_id]
          # If there is no school id
          failed_teacher_email_count += 1
          failed_teacher_email.append(row[:email])
          next
        elsif School.find_by(id: row[:school_id])
          # If there is a valid school id
          teacher_value = { first_name: row[:first_name], last_name: row[:last_name], education_level: row[:education_level],
          more_info: row[:more_info], personal_website: row[:personal_website], status: row[:status], school_id: row[:school_id] }
        end
        teacher_db.assign_attributes(teacher_value)
        if teacher_db.save
          update_teacher_count += 1
        else
          failed_teacher_email_count += 1
          failed_teacher_email.append(row[:email])
        end
        next
      elsif !row[:school_id]
        # If there is no school id (different from having invalid school id)
        new_school = [[row[:school_name], row[:school_city], row[:school_state], row[:school_website], row[:school_grade_level], row[:school_type], row[:school_tags], row[:school_nces_id]]]
        School.import school_column, new_school
        new_school_count += 1
        @newSchool = School.find_by(name: row[:school_name])
        if @newSchool
          teacher_value = [[row[:first_name], row[:last_name], row[:education_level], row[:email], row[:more_info], row[:personal_website], row[:snap], row[:status], @newSchool.id]]
        end
      elsif School.find_by(id: row[:school_id])
        # If there is a valid school id
        teacher_value = [[row[:first_name], row[:last_name], row[:education_level], row[:email], row[:more_info], row[:personal_website], row[:snap], row[:status], row[:school_id]]]
      else
        # school_id is provided, but invalid
        if row[:email]
          failed_teacher_email_count += 1
          failed_teacher_email.append(row[:email])
        else
          failed_teacher_noemail_count += 1
        end
        next
      end
      Teacher.import teacher_column, teacher_value
      success_teacher_count += 1
    end

    if success_teacher_count > 0
      flash[:success] = "Successfully imported #{success_teacher_count} teachers"
    end
    if new_school_count > 0
      flash[:notice] = "#{new_school_count} schools has been created"
    end
    if failed_teacher_email_count > 0
      flash[:alert] = "#{failed_teacher_email_count} teachers has failed with following emails:   "
      for email in failed_teacher_email do
        flash[:alert] += " [ #{email} ] "
      end
    end

    if failed_teacher_noemail_count > 0
      flash[:warning] = "#{failed_teacher_noemail_count} teachers has failed without emails"
    end

    if update_teacher_count > 0
      flash[:info] = "#{update_teacher_count} teachers has been updated"
    end

    redirect_to teachers_path
  end

  # TODO: This needs to be re-written.
  # If you are logged in and not an admin, this should fail.
  def create
    @school = School.new(school_params)
    # Find by email, but allow updating other info.
    @teacher = Teacher.find_by(email: teacher_params[:email])
    if @teacher && defined?(current_user.id) && (current_user.id == @teacher.id)
      params[:id] = current_user.id
      update
      return
    end
    @school = school_from_params
    if !@school.save
      flash[:alert] = "An error occurred! #{@school.errors.full_messages}"
      render "new"
      return
    end
    @teacher = @school.teachers.build(teacher_params)
    if @teacher.save
      @teacher.pending!
      flash[:success] = "Thanks for signing up for BJC, #{@teacher.first_name}! You'll hear from us shortly. Your email address is: #{@teacher.email}."
      TeacherMailer.form_submission(@teacher).deliver_now
      TeacherMailer.teals_confirmation_email(@teacher).deliver_now
      redirect_to root_path
    else
      redirect_to new_teacher_path, alert: "An error occurred while trying to submit teacher information. #{@teacher.errors.full_messages}"
    end
  end

  def edit
    load_teacher
    @school = @teacher.school
    @status = is_admin? ? "Admin" : "Teacher"
    @readonly = !is_admin?
  end

  def show
    load_teacher
    @school = @teacher.school
    @status = is_admin? ? "Admin" : "Teacher"
  end

  def update
    load_teacher
    @school = @teacher.school
    @teacher.assign_attributes(teacher_params)
    if (@teacher.email_changed? || @teacher.snap_changed?) && !is_admin?
      redirect_to edit_teacher_path(current_user.id), alert: "Failed to update your information. If you want to change your email or Snap! username, please email contact@bjc.berkeley.edu."
      return
    end
    if !@teacher.validated? && !current_user.admin?
      TeacherMailer.form_submission(@teacher).deliver_now
    end
    # Resends TEALS email only when said teacher changes status
    if @teacher.status_changed?
      TeacherMailer.teals_confirmation_email(@teacher).deliver_now
    end
    @teacher.save!
    if is_admin?
      redirect_to teachers_path, notice: "Saved #{@teacher.full_name}"
      return
    end
    redirect_to edit_teacher_path(current_user.id), notice: "Successfully updated your information"
  end

  def validate
    # TODO: Check if teacher is already denied (MAYBE)
    # TODO: move to model and add tests
    load_teacher
    @teacher.validated!
    @teacher.school.num_validated_teachers += 1
    @teacher.school.save!
    TeacherMailer.welcome_email(@teacher).deliver_now
    redirect_to root_path
  end

  def deny
    # TODO: Check if teacher is already validated (MAYBE)
    load_teacher
    @teacher.denied!
    @teacher.school.num_denied_teachers += 1
    @teacher.school.save!
    if !params[:skip_email].present?
      TeacherMailer.deny_email(@teacher, params[:reason]).deliver_now
    end
    redirect_to root_path
  end

  def delete
    if !is_admin?
      redirect_to root_path, alert: "Only administrators can delete!"
    else
      Teacher.delete(params[:id])
      redirect_to root_path
    end
  end

  private
    def load_teacher
      @teacher ||= Teacher.find(params[:id])
    end

    def deny_access
      redirect_to new_teacher_path, alert: "Email address or Snap username already in use. Please use a different email or Snap username."
    end

    def school_from_params
      @school ||= School.find_by(name: school_params[:name], city: school_params[:city], state: school_params[:state])
      @school ||= School.new(school_params)
    end

    def teacher_params
      params.require(:teacher).permit(:first_name, :last_name, :school, :email, :status, :snap,
        :more_info, :personal_website, :education_level)
    end

    def school_params
      params.require(:school).permit(:name, :city, :state, :website, :grade_level, :school_type, { tags: [] }, :nces_id)
    end

    def sanitize_params
      if params[:teacher]
        if params[:teacher][:status]
          params[:teacher][:status] = params[:teacher][:status].to_i
        end
        if params[:teacher][:education_level]
          params[:teacher][:education_level] = params[:teacher][:education_level].to_i
        end
      end

      if params[:school]
        if params[:school][:grade_level]
          params[:school][:grade_level] = params[:school][:grade_level].to_i
        end
        if params[:school][:school_type]
          params[:school][:school_type] = params[:school][:school_type].to_i
        end
      end
    end
end
