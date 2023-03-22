# frozen_string_literal: true

Given(/the following pages exist/) do |pages_table|
  default_params = {
    url_slug: "test_slug",
    title: "Test Page Title",
    html: "Test page body.",
    viewer_permissions: "Public",
    creator_id: Teacher.first.id,
    last_editor: Teacher.first
  }

  pages_table.symbolic_hashes.each do |page|
    Page.create!(default_params.merge(page))
  end
end

When(/^(?:|I )fill in the page HTML content with "([^"]*)"$/) do |value|
  find_field("HTML Content").set(value)
end

# TODO: This shouldn't rely on the HTML id.
When(/^I press the delete button for "(.*)"$/) do |slug|
  click_button("delete_" + slug)
end

# TODO: This shouldn't rely on the HTML id.
When(/^I press the edit button for "(.*)"$/) do |slug|
  click_link("edit_" + slug)
end

Then(/^The radio button "(.*)" should be checked$/) do |radio_button_name|
  expect(find_field(radio_button_name)).to be_checked
end

And(/^I should see a link named "(.*)"/) do |link_text|
  expect(page).to have_link(link_text)
end

And(/^I should see a nav link "(.*)"/) do |link_text|
  expect(page).to have_css("a.nav-link", text: link_text)
end

And(/^I should not see a nav link "(.*)"/) do |link_text|
  expect(page).not_to have_css("a.nav-link", text: link_text)
end

# It seems Capybara cannot interact with collapsibles nav links (probably
# because Capybara only interacts with server-side rendered HTML and not
# front-end Bootstrap JS). So, we have to use a workaround to "see" and
# "click" the hidden page link even though it is not visible.
# Technically this is bad practice, but it works for now.
And(/^I should have a(n active)? hidden page link "(.*)"/) do |active, link_text|
  expect(page).to have_css("a.nav-link", text: link_text, visible: false)
end

And(/^I should not have a(n active)? hidden page link "(.*)"/) do |active, link_text|
  expect(page).not_to have_css("a.nav-link", text: link_text, visible: false)
end

And(/^I follow the page link "(.*)"/) do |link_text|
  page.execute_script("document.getElementById('pagelink_#{link_text}').click();")
end
