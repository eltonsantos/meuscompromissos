require "application_system_test_case"

class CommitmentsTest < ApplicationSystemTestCase
  setup do
    @commitment = commitments(:one)
  end

  test "visiting the index" do
    visit commitments_url
    assert_selector "h1", text: "Commitments"
  end

  test "should create commitment" do
    visit commitments_url
    click_on "New commitment"

    fill_in "Description", with: @commitment.description
    fill_in "Progress", with: @commitment.progress
    fill_in "User", with: @commitment.user_id
    click_on "Create Commitment"

    assert_text "Commitment was successfully created"
    click_on "Back"
  end

  test "should update Commitment" do
    visit commitment_url(@commitment)
    click_on "Edit this commitment", match: :first

    fill_in "Description", with: @commitment.description
    fill_in "Progress", with: @commitment.progress
    fill_in "User", with: @commitment.user_id
    click_on "Update Commitment"

    assert_text "Commitment was successfully updated"
    click_on "Back"
  end

  test "should destroy Commitment" do
    visit commitment_url(@commitment)
    click_on "Destroy this commitment", match: :first

    assert_text "Commitment was successfully destroyed"
  end
end
