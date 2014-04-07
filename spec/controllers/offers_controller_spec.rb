require 'spec_helper'

describe OffersController do

  render_views #ensure that views are not throwing errors 

  describe '#home' do 
    before :each do 
      get :home 
    end

    it "is always successful" do 
      expect(response).to be_success 
    end

    it 'always renders its template' do 
      expect(response).to render_template :home
    end

    it "assigns fields' names to be filled by the user" do
      expect(assigns(:fields)).to eq(Offer.fields) #qua sarebbe molto più utile testare che abbia un valore 
    end
  end


  describe '#index' do 
    let(:fields) { {uid: 'test_user'} }
    before :each do 
      get :index, fields
    end

    it 'is always successful' do 
      expect(response).to be_success
    end

    it 'always renders its template' do 
      expect(response).to render_template :index
    end

    it 'assigns offers fetched from SponsorPay' do 
      expect(assigns(:offers)).to be_a Array
      expect(assigns(:offers).first).to be_a Offer
    end
  end

end