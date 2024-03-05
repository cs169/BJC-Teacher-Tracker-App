Feature: basic admin functionality

  As an admin
  So that I can see how many people are teaching BJC
  I can login in an see the dashboard

  Background: Has an Admin in DB
    Given the following teachers exist:
      | first_name | last_name | admin | email                      |
      | Joseph     | Mamoa     | true  | testadminuser@berkeley.edu |

  Scenario: Logging in as an admin
    Given I am on the BJC home page
    Given I have an admin email
    And I follow "Log In"
    Then I can log in with Google
    And I should see "BJC Teacher Dashboard"

  Scenario: Logging out as an admin
    Given I am on the BJC home page
    Given I have an admin email
    And I follow "Log In"
    Then I can log in with Google
    And I follow "Logout"
    Then I should see "Request Access to BJC Teacher Materials"
    Then I should see "Log In"

  Scenario: Viewing Teachers as an admin
    Given I am on the BJC home page
    Given I have an admin email
    And I follow "Log In"
    Then I can log in with Google
    When I go to the teachers page
    Then I should see "BJC Teachers"

# TODO: Add steps to check basic dashboard functions
# A search field should be visible on the index pages
# Check for a CSV button

# TODO: Checks for validation and deny belong here.

  Scenario: Logging in with non-admin, unregistered Google Account should fail
    Given I have a non-admin, unregistered Google email
    Given I am on the BJC home page
    And I follow "Log In"
    Then I can log in with Google
    And I should see "Please submit a new request."

  Scenario: Logging in with non-admin, unregistered Microsoft Account should fail
    Given I have a non-admin, unregistered Microsoft email
    Given I am on the BJC home page
    And I follow "Log In"
    Then I can log in with Microsoft
    And I should see "Please submit a new request."

  Scenario: Logging in with non-admin, unregistered Snap Account should fail
    Given I have a non-admin, unregistered Snap email
    Given I am on the BJC home page
    And I follow "Log In"
    Then I can log in with Snap
    And I should see "Please submit a new request."

  Scenario: Logging in with non-admin, unregistered Clever Account should fail
    Given I have a non-admin, unregistered Clever email
    Given I am on the BJC home page
    And I follow "Log In"
    Then I can log in with Clever
    And I should see "Please submit a new request."

  Scenario: Non-admin, unregistered user should not be able to see admin-only pages
    Given I have a non-admin, unregistered Google email
    Given I am on the BJC home page
    When  I go to the dashboard page
    Then  I should see "Only admins can access this page"
    And   I should be on the new teachers page

  Scenario: Edit teacher info as an admin
    Given the following schools exist:
      | name        | city     | state | website                  | grade_level | school_type |
      | UC Berkeley | Berkeley | CA    | https://www.berkeley.edu | university  | public      |
    Given the following teachers exist:
      | first_name | last_name | admin | email                    | school      | snap   |
      | Joseph     | Mamoa     | false | testteacher@berkeley.edu | UC Berkeley | alonzo |
    Given I am on the BJC home page
    Given I have an admin email
    And   I follow "Log In"
    Then  I can log in with Google
    When  I go to the teachers page
    When  I go to the edit page for Joseph Mamoa
    Then  I should see "Joseph"
    And   I enter my "First Name" as "Joe"
    And   I set my status as "Other - Please specify below."
    And   I set my education level target as "College"
    And   I press "Update"
    Then I see a confirmation "Saved"

  Scenario: Deny teacher as an admin
    Given the following schools exist:
      | name        | city     | state | website                  | grade_level | school_type |
      | UC Berkeley | Berkeley | CA    | https://www.berkeley.edu | university  | public      |
    Given the following teachers exist:
      | first_name | last_name | admin | email                    | school      |
      | Joseph     | Mamoa     | false | testteacher@berkeley.edu | UC Berkeley |
    Given I am on the BJC home page
    Given I have an admin email
    When  I follow "Log In"
    Then  I can log in with Google
    And   I press "❌" on Actions for first teacher
    Then  I should see "Reason"
    And   I should see "Deny Joseph Mamoa"
    And   I fill in "denial_reason" with "Test"
    And   I press "Cancel"
    And   I press "❌" on Actions for first teacher
    Then  the "denial_reason" field should not contain "Test"
    And   I fill in "denial_reason" with "Denial Reason"
    And   I capture the email count
    And   I press "Submit"
    Then  I can send a deny email
    Then I should see a new email sent out
    Then  I should see dialog box closed

  Scenario: Not logged in should not have access to edit
    Given the following schools exist:
      | name        | city     | state | website                  | grade_level | school_type |
      | UC Berkeley | Berkeley | CA    | https://www.berkeley.edu | university  | public      |
    Given the following teachers exist:
      | first_name | last_name | admin | email                    | school      |
      | Joseph     | Mamoa     | false | testteacher@berkeley.edu | UC Berkeley |
    When  I go to the edit page for Joseph Mamoa
    Then  should see "You need to log in to access this."

  Scenario: Filter all teacher info as an admin
    Given the following schools exist:
      | name        | city     | state | website                  | grade_level | school_type |
      | UC Berkeley | Berkeley | CA    | https://www.berkeley.edu | university  | public      |
    Given the following teachers exist:
      | first_name | last_name  | admin | email                     | school      | application_status |
      | Victor     | Validateme | false | testteacher1@berkeley.edu | UC Berkeley | Validated          |
      | Danny      | Denyme     | false | testteacher2@berkeley.edu | UC Berkeley | Denied             |
      | Peter      | Pendme     | false | testteacher3@berkeley.edu | UC Berkeley | Not Reviewed       |
    Given I am on the BJC home page
    Given I have an admin email
    And   I follow "Log In"
    Then  I can log in with Google
    When  I go to the teachers page
    And   I check "Not Reviewed"
    And   I uncheck "Validated"
    Then  I should see "Peter"
    Then  I should not see "Victor"
    Then  I should not see "Danny"
    And   I check "Validated"
    Then  I should see "Peter"
    Then  I should see "Victor"
    Then  I should not see "Danny"

  Scenario: View teacher info as an admin
    Given the following schools exist:
      | name        | city     | state | website                  | grade_level | school_type |
      | UC Berkeley | Berkeley | CA    | https://www.berkeley.edu | university  | public      |
    Given the following teachers exist:
      | first_name | last_name | admin | email                    | school      | snap   |
      | Joseph     | Test      | false | testteacher@berkeley.edu | UC Berkeley | alonzo |
    Given I am on the BJC home page
    Given I have an admin email
    And   I follow "Log In"
    Then  I can log in with Google
    When  I go to the teachers page
    And   I uncheck "Validated"
    When  I follow "Joseph Test"
    Then  I should see "Joseph Test"
    And   I should see "Edit Information"
    And   I should see "School"
    And   I should see "School Location"
    And   I should see "Email"
    And   I should see "Personal or Course Website"

  Scenario: Edit teacher info as an admin navigating from view only page to edit page
    Given the following schools exist:
      | name        | city     | state | website                  | grade_level | school_type |
      | UC Berkeley | Berkeley | CA    | https://www.berkeley.edu | university  | public      |
    Given the following teachers exist:
      | first_name | last_name | admin | email                    | school      | snap   |
      | Joseph     | Mamoa New | false | testteacher@berkeley.edu | UC Berkeley | alonzo |
    Given I am on the BJC home page
    Given I have an admin email
    And   I follow "Log In"
    Then  I can log in with Google
    When  I go to the teachers page
    And   I uncheck "Validated"
    When  I follow "Joseph Mamoa New"
    Then  I should see "Joseph Mamoa"
    And   I should see "Edit Information"
    And   I follow "Edit Information"
    And   I should see "Joseph"
    And   I enter my "First Name" as "Joe"
    And   I set my status as "Other - Please specify below."
    And   I set my education level target as "College"
    And   I press "Update"
    Then  I see a confirmation "Saved"

  Scenario: Should be able to resend welcome email
    Given the following schools exist:
      | name        | city     | state | website                  | grade_level | school_type |
      | UC Berkeley | Berkeley | CA    | https://www.berkeley.edu | university  | public      |
    Given the following teachers exist:
      | first_name | last_name | admin | email                    | school      | snap   | application_status |
      | Joseph     | Mamoa     | false | testteacher@berkeley.edu | UC Berkeley | alonzo | validated          |
    Given I am on the BJC home page
    Given I have an admin email
    And   I follow "Log In"
    Then  I can log in with Google
    When  I go to the teachers page
    When  I go to the edit page for Joseph Mamoa
    Then I should see a button named "Resend Welcome Email"

  Scenario: Admin can access new teacher button at teacher index page
    Given I am on the BJC home page
    Given I have an admin email
    And I follow "Log In"
    Then I can log in with Google
    And I should see "BJC Teacher Dashboard"
    Given I follow "Teachers"
    Then I should see "BJC Teachers"
    And I press "New Teacher"
    Then I should see "Request Access to BJC Teacher Materials"

  Scenario: Admin can access new school button at teacher index page
    Given I am on the BJC home page
    Given I have an admin email
    And I follow "Log In"
    Then I can log in with Google
    And I should see "BJC Teacher Dashboard"
    Given I follow "Schools"
    Then I should see "BJC Schools"
    And I press "New School"
    Then I should see "Add a School"

  Scenario: Request information from a teacher as an admin
    Given the following schools exist:
      | name        | city     | state | website                  | grade_level | school_type |
      | UC Berkeley | Berkeley | CA    | https://www.berkeley.edu | university  | public      |
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
    And I fill in "request_reason" with "Need more details on qualifications"
    And I press "Cancel"
    And I press "❓" on Actions for first teacher
    Then the "request_reason" field should not contain "Need more details on qualifications"
    And I capture the email count
    And I fill in "request_reason" with "Complete your profile details"
    And I press "Submit"
    Then I can send a request info email
    Then I should see a new email sent out
    Then I should see dialog box closed

  Scenario: Denying teacher without specifying a reason as an admin should not send email
    Given the following schools exist:
      | name        | city     | state | website                  | grade_level | school_type |
      | UC Berkeley | Berkeley | CA    | https://www.berkeley.edu | university  | public      |
    And the following teachers exist:
      | first_name | last_name | admin | email                    | school      |
      | Joseph     | Mamoa     | false | testteacher@berkeley.edu | UC Berkeley |
    And I am on the BJC home page
    And I have an admin email
    When I follow "Log In"
    Then I can log in with Google
    And I press "❌" on Actions for first teacher
    Then I should see "Reason"
    And I should see "Deny Joseph Mamoa"
    And I capture the email count
    And I fill in "denial_reason" with ""
    And I press "Submit"
    Then I should see dialog box remain open
    Then I should not see any new email sent out

  Scenario: Requesting more information from a teacher without specifying a reason as an admin should not send email
    Given the following schools exist:
      | name        | city     | state | website                  | grade_level | school_type |
      | UC Berkeley | Berkeley | CA    | https://www.berkeley.edu | university  | public      |
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
    And I capture the email count
    And I fill in "request_reason" with ""
    And I press "Submit"
    Then I should see dialog box remain open
    Then I should not see any new email sent out

# Scenario: Admin can import csv file. The loader should filter invalid record and create associate school.
#  Given the following schools exist:
#  |       name      |     city     |  state  |            website            |
#  | UC Berkeley   |   Berkeley   |   CA    |   https://bjc.berkeley.edu    |
#  Given I am on the BJC home page
#  Given I have an admin email
#  And I follow "Log In"
#  Then I can log in with Google
#  And I should see "BJC Teacher Dashboard"
#  Given I follow "Teachers"
#  And I uncheck "Validated"
#  And I press "Upload CSV"
#  Then The "#hidden_file_select_input" form is invalid
#  Then I attach the csv "features/test_utils/test_teacher_first.csv"
#  Then I should see "ank sha"
#  Then I should not see "Steve Gao"
#  Then I should not see "Haha He"
#  Then I should see "Wuho He"
#  Then I should see "Successfully created/updated 2 teachers"
#  Then I should see "1 schools has been created"
#  Then I should see "2 teachers has failed with following emails: [ steve.gao02112@gmail.com ] [ steve.fdso02112@gmail.com ]"
#  Then I follow "Schools"
#  Then I should see "uci"
#  Then I follow "Teachers"
#  Then I attach the csv "features/test_utils/test_teacher_second.csv"
#  Then I should see "anke sha"
#  Then I should see "Steve He"
#  Then I should see "Successfully created/updated 2 teachers"
#  Then I should see "2 teachers has failed with following emails: [ 1@gmail.com ] [ 2@gmail.com ]"

# Scenario: Importing with new schools model fields works
#  Given the following schools exist:
#  |       name      |     city     |  state  |            website            |
#  | UC Berkeley   |   Berkeley   |   CA    |   https://bjc.berkeley.edu    |
#  Given I am on the BJC home page
#  Given I have an admin email
#  And I follow "Log In"
#  Then I can log in with Google
#  And I should see "BJC Teacher Dashboard"
#  Given I follow "Teachers"
#  And I uncheck "Validated"
#  And I press "Upload CSV"
#  Then The "#hidden_file_select_input" form is invalid
#  Then I attach the csv "features/test_utils/test_teacher_third.csv"
#  Then I should see "ank sha"
#  Then I should not see "Steve Gao"
#  Then I should not see "Haha He"
#  Then I should see "Wuho He"
#  Then I should see "Successfully created/updated 2 teachers"
#  Then I should see "1 schools has been created"
#  Then I should see "2 teachers has failed with following emails: [ steve.gao02112@gmail.com ] [ steve.fdso02112@gmail.com ]"
