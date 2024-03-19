# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolsController, type: :request do
  fixtures :all

  let(:admin_teacher) { teachers(:admin) }

  before(:all) do
    @create_school_name = "University of California, Berkeley"
    @success_flash_alert = Regexp.new("Created #{@create_school_name} successfully.")
  end

  context "for a regular teacher" do
    it "denies teacher to create" do
      expect(School.find_by(name: @create_school_name)).to be_nil
      post schools_path, params: {
          school: {
              name: @create_school_name,
              city: "Berkeley",
              state: "CA",
              website: "www.berkeley.edu",
              school_type: "public",
              grade_level: "university",
              tags: [],
              nces_id: 123456789000
          }
      }
      expect(School.find_by(name: @create_school_name)).to be_nil
    end
  end

  context "for an admin" do
    before do
      log_in(admin_teacher)
    end

    it "allows admin to create" do
      expect(School.find_by(name: @create_school_name)).to be_nil
      post schools_path, params: {
          school: {
              name: @create_school_name,
              city: "Berkeley",
              country: "US",
              state: "CA",
              website: "www.berkeley.edu",
              school_type: "public",
              grade_level: "university",
              tags: [],
              nces_id: 123456789000
          }
      }
      expect(School.find_by(name: @create_school_name)).not_to be_nil
      expect(@success_flash_alert).to match flash[:success]
    end

    it "requires all fields filled" do
      expect(School.find_by(name: @create_school_name)).to be_nil
      begin
        post schools_path, params: {
          school: {
            name: @create_school_name,
            # request with missing city should fail
            country: "US",
            state: "CA",
            website: "www.berkeley.edu",
            school_type: "public",
            grade_level: "university",
            tags: [],
            nces_id: 123456789000
          }
        }
      rescue ActiveRecord::RecordInvalid => e
        expect(School.find_by(name: @create_school_name)).to be_nil
        expect(flash[:alert]).not_to be_present
      end

      begin
        post schools_path, params: {
          school: {
            name: @create_school_name,
            country: "US",
            city: "Berkeley",
            state: "CA",
            # request with missing website should also fail
            school_type: "public",
            grade_level: "university",
            tags: [],
            nces_id: 123456789000
        }
      }
      rescue ActiveRecord::RecordInvalid => e
        expect(School.find_by(name: @create_school_name)).to be_nil
        expect(flash[:alert]).not_to be_present
      end

      begin
        post schools_path, params: {
          school: {
            # missing name --> failed request
            country: "US",
            city: "Berkeley",
            state: "CA",
            website: "www.berkeley.edu",
            school_type: "public",
            grade_level: "university",
            tags: [],
            nces_id: 123456789000
          }
        }
      rescue ActiveRecord::RecordInvalid => e
        expect(School.find_by(name: @create_school_name)).to be_nil
        expect(flash[:alert]).not_to be_present
      end
    end

    it "requires proper inputs for fields" do
      expect(School.find_by(name: @create_school_name)).to be_nil
      # Incorrect state (not chosen from enum list)
      begin
        post schools_path, params: {
          school: {
            name: @create_school_name,
            country: "US",
            city: "Berkeley",
            state: "DISTRESS",
            website: "www.berkeley.edu",
            school_type: "public",
            grade_level: "university",
            tags: [],
            nces_id: 123456789000
          }
        }
      rescue ActiveRecord::RecordInvalid => e
        expect(School.find_by(name: @create_school_name)).to be_nil
        expect(flash[:alert]).not_to be_present
      end

      begin
        post schools_path, params: {
          school: {
            name: @create_school_name,
            country: "US",
            city: "Berkeley",
            state: "CA",
            website: "wwwberkeleyedu",
            school_type: "public",
            grade_level: "university",
            tags: [],
            nces_id: 123456789000
          }
        }
      rescue ActiveRecord::RecordInvalid => e
        expect(School.find_by(name: @create_school_name)).to be_nil
        expect(flash[:alert]).not_to be_present
      end

      # Incorrect school type
      expect { post schools_path, params: {
        school: {
            name: @create_school_name,
            country: "US",
            city: "Berkeley",
            state: "CA",
            website: "www.berkeley.edu",
            school_type: -1,
            grade_level: "university",
            tags: [],
            nces_id: 123456789000
        }
    }
      }.to raise_error(ArgumentError)
      expect(School.find_by(name: @create_school_name)).to be_nil

      # Incorrect grade_level
      expect { post schools_path, {
              params: {
                  school: {
                      name: @create_school_name,
                      country: "US",
                      city: "Berkeley",
                      state: "CA",
                      website: "www.berkeley.edu",
                      school_type: "public",
                      grade_level: -4,
                      tags: [],
                      nces_id: 123456789000
                  }
              }
          }
      }.to raise_error(ArgumentError)
      expect(School.find_by(name: @create_school_name)).to be_nil
    end

    it "succeeds with empty state field when country is not US" do
      expect(School.find_by(name: @create_school_name)).to be_nil
      post schools_path, params: {
        school: {
            name: @create_school_name,
            country: "CA", # Canada
            city: "Ottawa",
            state: "",
            website: "www.berkeley.edu",
            school_type: "public",
            grade_level: "university",
            tags: [],
            nces_id: 123456789000
        }
      }
      expect(School.find_by(name: @create_school_name)).not_to be_nil
      expect(@success_flash_alert).to match flash[:success]
    end

    it "fails with invalid country" do
      expect(School.find_by(name: @create_school_name)).to be_nil
      begin
        post schools_path, params: {
          school: {
              name: @create_school_name,
              country: "XX", # this is not an actual country code
              city: "Berkeley",
              state: "CA",
              website: "www.berkeley.edu",
              school_type: "public",
              grade_level: "university",
              tags: [],
              nces_id: 123456789000
          }
        }
      rescue ActiveRecord::RecordInvalid => e
        expect(School.find_by(name: @create_school_name)).to be_nil
        expect(flash[:alert]).not_to be_present
      end
    end

    it "does not create duplicate schools in the same city" do
      expect(School.where(name: @create_school_name).count).to eq 0

      post schools_path, params: {
        school: {
          name: @create_school_name,
          country: "US",
          city: "Berkeley",
          state: "CA",
          website: "www.berkeley.edu",
          school_type: "public",
          grade_level: "middle_school",
        }
      }
      expect(School.where(name: @create_school_name).count).to eq 1

      post schools_path, params: {
        school: {
          name: @create_school_name,
          country: "US",
          city: "Berkeley",
          state: "CA",
          website: "www.berkeley.edu",
          school_type: "public",
          grade_level: "university",
        }
      }
      expect(School.where(name: @create_school_name).count).to eq 1
    end
  end
end
