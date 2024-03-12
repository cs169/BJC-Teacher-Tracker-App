Feature: Request additional information for teacher application

  As an admin
  I want to be able to request additional information from teachers
  So that they can update their applications

  Background: Has an Admin in DB
    Given the following teachers exist:
      | first_name | last_name | admin | email                      |
      | Joseph     | Mamoa     | true  | testadminuser@berkeley.edu |

  Scenario: Admin requests more information and teacher sees notification upon login
    Given the following schools exist:
      |       name      |     country     |     city     |  state  |            website            |  grade_level  |  school_type  |
      |   UC Berkeley   |       US        |   Berkeley   |   CA    |   https://www.berkeley.edu    |  university   |     public    |
    And the following teachers exist:
      | first_name | last_name | admin | email                    | school      |
      | Joseph     | Mamoa     | false | testteacher@berkeley.edu | UC Berkeley |
    And I am on the BJC home page
    And I have an admin email
    When I follow "Log In"
    Then I can log in with Google
    And I press "❓" on Actions for first teacher
    Then I should see "Reason"
    And I should see "Request Info from Joseph Mamoa"
    And I fill in "request_reason" with "Please provide more details on your teaching experience"
    And I press "Submit"
    Then I can send a request info email
    And I follow "Logout"

    Given I am on the BJC home page
    And I have a teacher Google email "testteacher@berkeley.edu"
    And I follow "Log In"
    Then I can log in with Google
    And I should see a "warning" flash message "Your application is requested to be updated. You may update your information. Please check your email for more information."

  Scenario: Teacher updates information as requested and sees updated application status upon re-login
    Given the following schools exist:
      |       name      |     country     |     city     |  state  |            website            |  grade_level  |  school_type  |
      |   UC Berkeley   |       US        |   Berkeley   |   CA    |   https://www.berkeley.edu    |  university   |     public    |
    And the following teachers exist:
      | first_name | last_name | admin | email                    | school      | application_status |
      | Joseph     | Mamoa     | false | testteacher@berkeley.edu | UC Berkeley | info_needed        |
    And I am on the BJC home page
    And I have a teacher Google email "testteacher@berkeley.edu"
    And I follow "Log In"
    Then I can log in with Google
    And I should see a "warning" flash message "Your application is requested to be updated. You may update your information. Please check your email for more information."
    And I fill in "teacher_more_info" with "I have been teaching for 5 years at a high school and have led several programming clubs."
    And I press "Update"
    Then I should see a "info" flash message "Successfully updated your information"
    And I follow "Logout"

    Given I am on the BJC home page
    And I have a teacher Google email "testteacher@berkeley.edu"
    And I follow "Log In"
    Then I can log in with Google
    And I should see a "warning" flash message "Your application is not reviewed. You may update your information. Please check your email for more information."
