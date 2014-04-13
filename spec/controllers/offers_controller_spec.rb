require 'spec_helper'

describe OffersController do

  describe '#home' do 
    before :each do 
      get :home 
    end

    it "is always successful" do 
      expect(response).to be_success 
    end

    it 'always renders "home" template' do 
      expect(response).to render_template :home
    end

    it "assigns fields' names to be filled by the user" do
      expect(assigns(:fields)).to eq(Offer.fields) #qua sarebbe molto più utile testare che abbia un valore 
    end
  end


  describe '#index' do 
    let(:fields) { {uid: 'test_user'} }
    before :each do 
      @fetched = [double(Offer), double(Offer)]
      allow(Offer).to receive(:fetch_offers).with(hash_including(fields)).and_return(@fetched) if Offer.respond_to? :fetch_offers
      xhr :get, :index, fields
    end

    it 'is always successful' do 
      expect(response).to be_success
    end

    it 'always renders "index" template' do 
      expect(response).to render_template :index
    end

    it 'assigns any value returned from the model' do 
      expect(assigns(:offers)).to eq @fetched
    end
  end
end