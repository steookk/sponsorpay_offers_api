require 'spec_helper'

feature "get offers", :js => true do
  background do 
    visit root_path
  end

  describe 'success' do 
    scenario "Offers are provided" do 
      within "#parameters" do  
        expect(all('.form-group').first).to have_content 'Mandatory'
        fill_in "uid",                    :with => "stefano1234"
        fill_in "pub0",                   :with => "campaign_test"
        fill_in "page",                   :with => "1"
        click_button "Get offers"
      end
      expect(page).to have_selector('.offer')
    end 

    scenario "Offers are not provided" do
      fill_in "uid",                    :with => "stefano1234"
      fill_in "pub0",                   :with => "campaign_test"
      fill_in "page",                   :with => "1"
      click_button "Get offers"
      expect(page).to have_selector('.alert-info') 
      expect(page).to have_content('No offers')
    end
  end

  describe 'failure' do 
    scenario "Mandatory fields were not provided" do 
      fill_in "uid",                    :with => ""
      fill_in "pub0",                   :with => "campaign_test"
      fill_in "page",                   :with => "1"
      click_button "Get offers"
      expect(page).to have_selector('.alert-danger')
    end
  end
end