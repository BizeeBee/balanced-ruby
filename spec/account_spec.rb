require "spec_helper"

describe Balanced::Account do
  describe ".complete_kyc" do
    before do 
      @temporary_kyc_account = mock(Balanced::Account, save: true)
      Balanced::Account.stub(:new) { subject }
    end 

    subject { @temporary_kyc_account }

    after do  
      Balanced::Account.complete_kyc(
        {
          merchant_uri: "temporary-kyc-merchant-uri", 
          email_address: "john.doe@example.com"
        }
      )
    end 

    specify {
      Balanced::Account.should_receive(:new).with(
        {
          merchant_uri: "temporary-kyc-merchant-uri", 
          email_address: "john.doe@example.com"
        }
      )
    }

    specify {
      @temporary_kyc_account.should_receive(:save)
    }
  end

  describe ".find_by_email" do
    use_vcr_cassette
    before do
      api_key = Balanced::ApiKey.new.save
      Balanced.configure api_key.secret
      @marketplace = Balanced::Marketplace.new.save
      card = Balanced::Card.new(
        :card_number => "5105105105105100",
        :expiration_month => "12",
        :expiration_year => "2015",
      ).save
      buyer = Balanced::Marketplace.my_marketplace.create_buyer(
        "john.doe@example.com",
        card.uri
      )
    end

    context "email address is in system" do
      use_vcr_cassette
      it "should return account object" do
        Balanced::Account.find_by_email("john.doe@example.com").should be_instance_of Balanced::Account
      end
    end

    context "email address does not exist" do
      use_vcr_cassette
      it "should return nil" do
        Balanced::Account.find_by_email("foo@bar.com").should be_nil
      end
    end
  end
end
