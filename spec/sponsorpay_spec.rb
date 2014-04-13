require 'spec_helper'

# SponsorpPay is located in /lib
describe SponsorPay do 
  after :each do 
    SponsorPay.reset
  end

  describe 'SponsorPay.offers' do
    subject { SponsorPay.offers('player1', {pub0: 'campaign2', page: '2', ps_time: '1312211903'}) }

    context 'mandatory settings are NOT setted' do 
      it "raises an error" do 
        expect {subject}.to raise_error(SponsorPay::SponsorPayError)
      end
    end

    context 'mandatory settings are setted' do 
      before :each do 
        set_sponsorpay_mandatory_settings #spec helper
        allow(Time).to receive(:now).and_return('1312553361') #timestamp stub
      end

      context 'offers are available' do 
        before :each do 
          WebMock::API.stub_request(:get, SponsorPay.endpoint + 'offers' + '.json')
                 .with(query: hash_including( {'uid' => 'player1', 'appid' => '157',
                                    'hashkey' => '69a16efcca5677c4effbbc1b16249754b4f21d1c'} ), 
                       headers: {'Accept-Encoding' => /gzip.*/,'Connection' => 'Keep-Alive'})
                 .to_return(:status => 200, :body => fixture("offers.json"), :headers => {})
        end
        #thanks to hash_including I can check the presence of:
        # 1. user mandatory field; 2. mandatory setting 3. correct calculation of hashkey
        let(:meta_methods) { [:code, :message, :count, :pages, :information] }

        it 'responds to meta informations methods' do
          meta_methods.each do |method|
            expect(subject).to respond_to(method)
          end
        end

        it "has a SUCCESS code" do 
          expect(subject.code).to eq('OK')
        end

        it 'responds to .offers method' do 
          expect(subject).to respond_to(:offers)
        end

        it 'responds with an array of offers' do
          expect(subject.offers).to be_a Array
        end

        describe "each offer" do 
          let(:offer_methods) { [:title, :offer_id, :teaser, :required_actions, 
                                :link, :offer_types, :thumbnail, :payout, :time_to_payout] }
          it "responds to offer specific methods" do 
            offer_methods.each do |method|
              expect(subject.offers.first).to respond_to(method)
            end
          end
        end
      end

      context 'offers are NOT available' do 
        before :each do 
          WebMock::API.stub_request(:get, SponsorPay.endpoint + 'offers' + '.json')
                          .with(query: hash_including( {'uid' => 'player1', 'appid' => '157',
                                    'hashkey' => '69a16efcca5677c4effbbc1b16249754b4f21d1c'} ), 
                                headers: {'Accept-Encoding' => /gzip.*/,'Connection' => 'Keep-Alive'})
                          .to_return(:status => 200, :body => fixture("no_offers.json"), :headers => {})
        end 

        it "responds with a NO_CONTENT code" do 
          expect(subject.code).to eq('NO_CONTENT')
        end

        it "responds with an empty array of offers" do 
          expect(subject.offers).to be_a Array
          expect(subject.offers).to be_empty
        end
      end

      context 'errors' do 
        before :each do 
          WebMock::API.stub_request(:get, SponsorPay.endpoint + 'offers' + '.json')
                          .with(query: hash_including( {'uid' => 'player1', 'appid' => '157',
                                    'hashkey' => '69a16efcca5677c4effbbc1b16249754b4f21d1c'} ), 
                                headers: {'Accept-Encoding' => /gzip.*/,'Connection' => 'Keep-Alive'})
                          .to_return(:status => 400, :body => fixture("invalid_uid.json"), :headers => {})
        end

        it "responds with a error code" do
          expect {subject}.to raise_error(SponsorPay::SponsorPayError, 'HTTP 400: ERROR_INVALID_UID')
        end
      end
    end
  end


  describe 'mandatory settings' do 
    it 'responds to read accessors' do 
      SponsorPay::Configuration::SETTINGS.each do |setting|
        expect(SponsorPay.respond_to? setting).to be_true
      end
    end

    it 'responds to write accessors' do
      SponsorPay::Configuration::SETTINGS.each do |setting|
        expect(SponsorPay.respond_to? "#{setting}=").to be_true
      end
    end

    describe 'SponsorPay.settings' do 
      subject { SponsorPay.settings }
      it 'returns an hash with settings' do
        expect(subject.keys).to eq SponsorPay::Configuration::SETTINGS
      end
    end
  end

  describe 'options' do 
    it 'responds to read accessors' do 
      SponsorPay::Configuration::OPTIONS.each do |option|
        expect(SponsorPay.respond_to? option).to be_true
      end
    end

    it 'responds to write accessors' do 
      SponsorPay::Configuration::OPTIONS.each do |option|
        expect(SponsorPay.respond_to? "#{option}=").to be_true
      end
    end

    describe 'SponsorPay.options' do 
      subject { SponsorPay.options }
      it 'returns an hash with options' do
        expect(subject.keys).to eq SponsorPay::Configuration::OPTIONS
      end

      it 'returns a hash with current values' do 
        expect(subject[:endpoint]).to eq SponsorPay.endpoint
      end
    end
  end

  describe 'SponsorPay.reset (alias setup)' do 
    it "is aliased as #setup" do 
      expect(SponsorPay).to respond_to(:setup)
    end

    it 'sets options to default values' do 
      SponsorPay.setup
      SponsorPay::Configuration::OPTIONS.each do |option|
        expect(SponsorPay.send(option)).to eq SponsorPay::Configuration.const_get("DEFAULT_#{option.upcase}")
      end
    end

    it 'sets settings to nil values' do 
      SponsorPay.setup
      SponsorPay::Configuration::SETTINGS.each do |setting|
        expect(SponsorPay.send(setting)).to be nil
      end
    end
  end

  describe 'SponsorPay.configure' do 
    it 'allows to set values as when using Sponsorpay.setter' do 
      SponsorPay.configure do |config|
        config.endpoint = 'test'
      end
      expect(SponsorPay.endpoint).to eq('test')
    end
  end


end