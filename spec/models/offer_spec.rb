require 'spec_helper'

describe Offer do 
  describe '.fields' do 
    it "returns an array" do 
      expect(Offer.fields).to be_a Array 
    end

    it 'returns an array of fields to be filled by the user prior to sending a request to SponsorPay' do 
      expect(Offer.fields).to include(:uid)
    end
  end

  describe '.mandatory' do 
    it 'returns whether a field must be filled by the user in order to get offers' do 
      expect(Offer.mandatory? :uid).to be_true 
      expect(Offer.mandatory? :pub0).to be_false
    end
  end

  describe '.new' do 
    it "returns a valid Offer object" do 
      expect(Offer.new(double title: 'test', offer_id: '1')).to be_a Offer
    end
  end

  describe '#method_missing' do 
    subject(:offer) { Offer.new(double title: 'test', offer_id: '1') }

    it 'delegates to the object given during creation' do 
      expect(offer.title).to eq('test') 
    end
  end

  describe "#error_message" do 
    let(:offer) { Offer.new(nil) }
    let(:error) { 'this is a test error' }

    it "sets a message" do 
      offer.error_message = error
      expect(offer.error_message).to eq(error)
    end
  end

  describe '.fetch_offers' do 
    shared_examples_for 'wrong parameters' do |fields, error|
      it "returns an Offer object not containing any data" do 
        expect {Offer.fetch_offers(fields).title}.to raise_error
      end

      it 'returns an Offer object responding to an error message' do 
        expect(Offer.fetch_offers(fields).error_message).to match error
      end
    end
    
    context "validation fails (mandatory SponsorPay parametes are not given)" do 
      context 'mandatory fields are not present' do 
        it_behaves_like 'wrong parameters', {page: '1', pub0: 'campaign'}, /.*keys are missing/
      end

      context 'mandatory fields are blank' do 
        it_behaves_like 'wrong parameters', {uid: '', page: '1', pub0: 'campaign'}, /.*keys are missing/
      end

    end

    context "validation is successful" do 
      let(:fields) { {uid: '123', page: '1', pub0: 'campaign'} }

      context "offers are available" do 
        before do 
          allow(SponsorPay).to receive(:offers)
                                .with('123', fields)
                                .and_return( double(count: '2', offers: [ {title: 'test1'}, {title: 'test2'}]) )
        end

        it "returns an array of Offer objects" do 
          expect(Offer.fetch_offers(fields)).to be_a Array
          expect(Offer.fetch_offers(fields).first).to be_a Offer
          expect(Offer.fetch_offers(fields).length).to be 2 
        end
      end

      context "offers are not available" do 
        before do 
          allow(SponsorPay).to receive(:offers).and_return( double(count: '0', offers: []) )
        end

        it "returns an empty array" do 
          expect(Offer.fetch_offers(fields).length).to be 0
        end
      end

      context "SponsorPay raises errors" do 
        before do 
          allow(SponsorPay).to receive(:offers).and_raise SponsorPay::SponsorPayError, 'ERROR_TEST'
        end

        it_behaves_like 'wrong parameters', {uid: '123', page: 'not valid page', pub0: '1'}, /ERROR.*/
      end

      describe "cleaning up parameters to be passed to SponsorPay" do 
        it "deletes keys which are not declared as fields" do 
          dirty_fields = fields.clone
          dirty_fields[:action] = 'index'
          expect(SponsorPay).to receive(:offers).with('123', fields).and_return(double( offers: []))
          Offer.fetch_offers(dirty_fields)
        end

        it "deletes blank fields" do 
          fields[:page] = ''; fields[:pub0] = '    '
          expect(SponsorPay).to receive(:offers).with('123', {uid: '123'}).and_return(double( offers: []))
          Offer.fetch_offers(fields)
        end

        it "strips leading and trailing spaces from fields" do 
          dirty_fields = fields.clone
          dirty_fields[:uid] = '  123   '
          expect(SponsorPay).to receive(:offers).with('123', fields).and_return(double( offers: []))
          Offer.fetch_offers(dirty_fields)
        end
      end
    end
  end

end