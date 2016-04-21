require 'test_helper'

class UserAdjustsBankBalanceTest < ActionDispatch::IntegrationTest
  test "balance is not adjusted when transaction dips below zero" do
    gertrude = Student.create(name: "Gertrude", balance: 10)
    bertha   = Student.create(name: "Bertha", balance: 40)

    visit bank_path
    select "Gertrude", from: "transfer_from[student_id]"
    select "Bertha", from: "transfer_to[student_id]"
    fill_in "amount", with: 15
    click_on "Submit"

    within('table .student:first') do
      assert page.has_content?("Gertrude")
      assert page.has_content?("10")
    end

    within('table .student:last') do
      assert page.has_content?("Bertha")
      assert page.has_content?("40")
    end
  end
end
