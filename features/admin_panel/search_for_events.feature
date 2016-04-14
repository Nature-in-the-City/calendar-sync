@javascript
Feature: Search for events in admin panel
  As an admin
  So that I can quickly find a specific event
  I want to be able to search for a specific event in the admin panel
  
Background:
  Given the following events exist:
    | name                    | start                 | end                 | status    |
    | Hike in the city        | Aug-21-2018 12:00 PM  | Aug-21-2018 4:00 PM | pending   |
    | Rollerblade in the park | Aug-31-2018 9:00 AM   | Aug-31-2018 1:00 PM | approved  |
    Given that I am logged in as the admin
    And I am on the admin page
    And I see the "Search tab"

Scenario: search for event by name
  When I select "Name" from "Search for event by"
  And I fill in "Hike in the city" in "Search field"
  And I click "Search"
  Then I should see "Hike in the city" in the results panel

Scenario: search for event by date
  When I select "Start date" from "Search for event by"
  And I fill in "August 2018" in "Search field"
  And I click "Search"
  Then I should see "Hike in the city" in the "Results panel"
  And I should see "Rollerblade in the park" in the results panel

Scenario: search for event by name with incorrect name
  When I select "Name" from "Search for event by"
  And I fill in "hike in the citie"
  And I click "Search"
  Then I should see "Sorry, no events with the name 'hike in the citie' were found"