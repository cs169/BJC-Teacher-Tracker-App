# frozen_string_literal: true

# TL;DR: YOU SHOULD DELETE THIS FILE
#
# This file was generated by Cucumber-Rails and is only here to get you a head start
# These step definitions are thin wrappers around the Capybara/Webrat API that lets you
# visit pages, interact with widgets and make assertions about page content.
#
# If you use these step definitions as basis for your features you will quickly end up
# with features that are:
#
# * Hard to maintain
# * Verbose to read
#
# A much better approach is to write your own higher level step definitions, following
# the advice in the following blog posts:
#
# * http://benmabey.com/2008/05/19/imperative-vs-declarative-scenarios-in-user-stories.html
# * http://dannorth.net/2011/01/31/whose-domain-is-it-anyway/
# * http://elabs.se/blog/15-you-re-cuking-it-wrong
#


require "uri"
require "cgi"
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "selectors"))

module WithinHelpers
  def with_scope(locator, &block)
    locator ? within(*selector_for(locator), &block) : yield
  end
end
World(WithinHelpers)


Given(/^(?:|I )am on (.+)$/) do |page_name|
  visit path_to(page_name)
end

When(/^(?:|I )go to (.+)$/) do |page_name|
  visit path_to(page_name)
end

When(/^(?:|I )press "([^"]*)"(?: within (.*[^:]))?$/) do |button, scope|
  with_scope(scope || '"html"') do
    click_button(button)
  end
end

When(/^(?:|I )follow "([^"]*)"$/) do |link|
  click_link(link)
end

When(/^(?:|I )fill in "([^"]*)" with "([^"]*)"$/) do |field, value|
  fill_in(field, with: value)
end

When(/^(?:|I )fill in TinyMCE email form with "([^"]*)"$/) do |value|
  page.execute_script('$(tinymce.editors[0].setContent("' + value + '"))')
end

When(/^(?:|I )follow the first "([^"]*)" link$/) do |link_text|
  first("a", text: link_text).click
end

When(/^(?:|I )press the first "([^"]*)" button$/) do |button_text|
  first("button", text: button_text).click
end

Then(/^(?:|I )accept the popup alert$/) do
  page.driver.browser.switch_to.alert.accept
end

When(/^(?:|I )fill in "([^"]*)" for "([^"]*)"$/) do |value, field|
  fill_in(field, with: value)
end

# Use this to fill in an entire form with data from a table. Example:
#
#   When I fill in the following:
#     | Account Number | 5002       |
#     | Expiry date    | 2009-11-01 |
#     | Note           | Nice guy   |
#     | Wants Email?   |            |
#
# TODO: Add support for checkbox, select or option
# based on naming conventions.
#
When(/^(?:|I )fill in the following:$/) do |fields|
  fields.rows_hash.each do |field, value|
    if ["State", "Grade Level", "School Type"].include?(field)
      select(value, from: field)
    else
      fill_in(field, with: value)
    end
  end
end

When(/^(?:|I )select "([^"]*)" from "([^"]*)"$/) do |value, field|
  select(value, from: field)
end

When(/^(?:|I )check "([^"]*)"$/) do |field|
  check(field, allow_label_click: true)
end

When(/^(?:|I )uncheck "([^"]*)"$/) do |field|
  uncheck(field, allow_label_click: true)
end

When(/^(?:|I )choose "([^"]*)"$/) do |field|
  choose(field)
end

When(/^(?:|I )attach the file "([^"]*)" to "([^"]*)"$/) do |path, field|
  attach_file(field, File.expand_path(path))
end

Then(/^(?:|I )should see "([^"]*)"$/) do |text|
  expect(page).to have_content(text)
end

Then(/^(?:|I )should see hidden element "([^"]*)"$/) do |text|
  Capybara.ignore_hidden_elements = false
  expect(page.html).to match(/#{text}/)
  Capybara.ignore_hidden_elements = true
end

Then(/^(?:|I )should see \/([^\/]*)\/$/) do |regexp|
  regexp = Regexp.new(regexp)
  expect(page).to have_xpath("//*", text: regexp)
end

Then(/^(?:|I )should not see "([^"]*)"$/) do |text|
  expect(page).to have_no_content(text)
end

Then(/^(?:|I )should not see \/([^\/]*)\/$/) do |regexp|
  regexp = Regexp.new(regexp)
  expect(page).to have_no_xpath("//*", text: regexp)
end

Then(/^the "([^"]*)" field(?: within (.*))? should contain "([^"]*)"$/) do |field, parent, value|
  with_scope(parent) do
    field = find_field(field)
    field_value = (field.tag_name == "textarea") ? field.text : field.value
    expect(field_value).to match(/#{value}/)
  end
end

Then(/^the "([^"]*)" field(?: within (.*))? should not contain "([^"]*)"$/) do |field, parent, value|
  with_scope(parent) do
    field = find_field(field)
    field_value = (field.tag_name == "textarea") ? field.text : field.value
    if field_value.respond_to? :should_not
      field_value.should_not =~ /#{value}/
    else
      assert_no_match(/#{value}/, field_value)
    end
  end
end

Then(/^the "([^"]*)" field should have the error "([^"]*)"$/) do |field, error_message|
  element = find_field(field)
  classes = element.find(:xpath, "..")[:class].split(" ")

  form_for_input = element.find(:xpath, "ancestor::form[1]")
  using_formtastic = form_for_input[:class].include?("formtastic")
  error_class = using_formtastic ? "error" : "field_with_errors"

  if classes.respond_to? :should
    classes.should include(error_class)
  else
    assert classes.include?(error_class)
  end

  if page.respond_to?(:should)
    if using_formtastic
      error_paragraph = element.find(:xpath, '../*[@class="inline-errors"][1]')
      error_paragraph.should have_content(error_message)
    else
      page.should have_content("#{field.titlecase} #{error_message}")
    end
  else
    if using_formtastic
      error_paragraph = element.find(:xpath, '../*[@class="inline-errors"][1]')
      assert error_paragraph.has_content?(error_message)
    else
      assert page.has_content?("#{field.titlecase} #{error_message}")
    end
  end
end

Then(/^the "([^"]*)" field should have no error$/) do |field|
  element = find_field(field)
  classes = element.find(:xpath, "..")[:class].split(" ")
  if classes.respond_to? :should
    classes.should_not include("field_with_errors")
    classes.should_not include("error")
  else
    assert !classes.include?("field_with_errors")
    assert !classes.include?("error")
  end
end

Then(/^the "([^"]*)" checkbox(?: within (.*))? should be checked$/) do |label, parent|
  with_scope(parent) do
    field_checked = find_field(label)["checked"]
    if field_checked.respond_to? :should
      field_checked.should be_true
    else
      assert field_checked
    end
  end
end

Then(/^the "([^"]*)" checkbox(?: within (.*))? should not be checked$/) do |label, parent|
  with_scope(parent) do
    field_checked = find_field(label)["checked"]
    if field_checked.respond_to? :should
      field_checked.should be_false
    else
      assert !field_checked
    end
  end
end

Then(/^(?:|I )should be on (.+)$/) do |page_name|
  current_path = URI.parse(current_url).path
  expect(current_path).to eq path_to(page_name)
end

Then(/^(?:|I )should have the following query string:$/) do |expected_pairs|
  query = URI.parse(current_url).query
  actual_params = query ? CGI.parse(query) : {}
  expected_params = {}
  expected_pairs.rows_hash.each_pair { |k, v| expected_params[k] = v.split(",") }

  expect(actual_params).to eq expected_params
end

Then(/^show me the page$/) do
  save_and_open_page
end

Then(/^(?:|I )should see a button named "([^"]*)"$/) do |text|
  expect(page).to have_button(text)
end

Then(/^(?:|I )should not see a button named "([^"]*)"$/) do |text|
  expect(page).to have_no_button(text)
end

Then(/^"([^"]*)" should be selected for "([^"]*)"(?: within "([^"]*)")?$/) do |value, field, selector|
  with_scope(selector) do
    field_labeled(field).find(:xpath, ".//option[@selected = 'selected'][text() = '#{value}']").should be_present
  end
end

Then("I should see dialog box remain open") do
  expect(page).to have_css(".js-denialModal.show")
end

Then("I should see dialog box closed") do
  expect(page).to have_no_css(".js-denialModal.show")
end

When(/^(?:|I )press "([^"]*)" on Actions for first teacher$/) do |button|
  teacher_actions_scope = "#DataTables_Table_0 tbody tr:first-child"

  within(teacher_actions_scope) do
    click_button(button)
  end
end
