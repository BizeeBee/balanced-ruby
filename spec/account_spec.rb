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
end
