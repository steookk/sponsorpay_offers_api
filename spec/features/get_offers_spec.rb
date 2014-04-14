require 'spec_helper'

feature "get offers", :js => true do
  background do
    WebMock.allow_net_connect!
    set_sponsorpay_mandatory_settings #spec helper
    visit root_path
  end

  describe 'success' do 
    background do 
      WebMock::API.stub_request(:get, 'http://api.sponsorpay.com/feed/v1/offers.json')
         .with(query: hash_including( 'pub0' => 'yes_offers' ))
         .to_return(:status => 200, :body => fixture("offers.json"), :headers => {})
      WebMock::API.stub_request(:get, 'http://api.sponsorpay.com/feed/v1/offers.json')
         .with(query: hash_including( 'pub0' => 'no_offers' ))
         .to_return(:status => 200, :body => fixture("no_offers.json"), :headers => {})
    end

    scenario "SponsorPay provides with offers" do 
      within "#parameters" do  
        expect(all('.form-group').first).to have_content 'Mandatory'
        fill_in "uid",                    :with => "stefano1234"
        fill_in "pub0",                   :with => "yes_offers"
        fill_in "page",                   :with => "1"
        click_button "Get offers"
      end
      expect(page).to have_selector('.offers')
    end 

    scenario "SponsorPay does not provide with offers" do
      fill_in "uid",                    :with => "stefano1234"
      fill_in "pub0",                   :with => "no_offers"
      fill_in "page",                   :with => "1"
      click_button "Get offers"
      expect(page).to have_selector('.alert-info') 
      expect(page).to have_content('No offers')
    end
  end

  describe 'failure' do 
    background do
      WebMock::API.stub_request(:get, 'http://api.sponsorpay.com/feed/v1/offers.json')
         .with(query: hash_including( 'page' => 'page 300' ))
         .to_return(:status => 400, :body => fixture("invalid_uid.json"), :headers => {})
    end

    scenario "Mandatory fields were not provided" do 
      fill_in "uid",                    :with => ""
      fill_in "pub0",                   :with => "campaign_test"
      fill_in "page",                   :with => "1"
      click_button "Get offers"
      expect(page).to have_selector('.alert-danger')
      expect(page).to have_content(/.*keys are missing/)
    end

    scenario "Mandatory settings are missing" do 
      SponsorPay.configure do |config|
        config.appid = nil
      end
      fill_in "uid",                    :with => "stefano1234"
      fill_in "pub0",                   :with => "campaign_test"
      fill_in "page",                   :with => "1"
      click_button "Get offers"
      expect(page).to have_selector('.alert-danger')
      expect(page).to have_content(/.*settings are missing/)
    end

    scenario "SponsorPay does not accept a value or reply with a generic server error" do 
      fill_in "uid",                    :with => "stefano1234"
      fill_in "pub0",                   :with => "campaign_test"
      fill_in "page",                   :with => "page 300"
      click_button "Get offers"
      expect(page).to have_selector('.alert-danger')
      expect(page).to have_content(/ERROR.*/)
    end
  end
end