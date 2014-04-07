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

  describe '.fetch_offers' do 
    context "mandatory SponsorPay fields are not passed or they are blank" do 
      let(:fields_not_present) { {page: '1', pub0: 'campaign'} }
      let(:fields_blank) { {uid: '', page: '1', pub0: 'campaign'} }
      
      it "returns nil" do 
        expect(Offer.fetch_offers(fields_not_present)).to be_nil 
        expect(Offer.fetch_offers(fields_blank)).to be_nil
      end
    end

    context "mandatory SponsorPay fields are passed" do 
      let(:fields) { {uid: '123', page: '1', pub0: 'campaign'} }

      context "offers are available" do 
        before do 
          allow(SponsorPay).to receive(:offers).and_return( double(meta: { count: '2'}, offers: [ {title: 'test1'}, {title: 'test2'}]) )
        end

        it "returns an array of Offer objects" do 
          expect(Offer.fetch_offers(fields)).to be_a Array
          expect(Offer.fetch_offers(fields).first).to be_a Offer
          expect(Offer.fetch_offers(fields).length).to be 2 
        end
      end

      context "offers are not available" do 
        before do 
          allow(SponsorPay).to receive(:offers).and_return( double(meta: { count: '0'}, offers: []) )
        end

        it "returns an empty array" do 
          expect(Offer.fetch_offers(fields).length).to be 0
        end
      end

      describe "cleaning up parameters to be passed to SponsorPay" do 
        it "deletes keys which are not declared as fields" do 
          dirty_fields = fields.clone
          dirty_fields[:action] = 'index'
          expect(SponsorPay).to receive(:offers).with(fields).and_return(double( offers: []))
          Offer.fetch_offers(dirty_fields)
        end

        it "deletes blank fields" do 
          fields[:page] = ''; fields[:pub0] = '    '
          expect(SponsorPay).to receive(:offers).with( {uid: '123'} ).and_return(double( offers: []))
          Offer.fetch_offers(fields)
        end

        it "strips leading and trailing spaces from fields" do 
          dirty_fields = fields.clone
          dirty_fields[:uid] = '  123   '
          expect(SponsorPay).to receive(:offers).with( fields ).and_return(double( offers: []))
          Offer.fetch_offers(dirty_fields)
        end
      end
    end
  end

end