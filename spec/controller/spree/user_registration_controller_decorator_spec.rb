require 'spec_helper' 

describe   Spree::UserRegistrationsController,:type=>"controller" do
	#include Devise::TestHelpers
	describe " UserRegistrationsController" do
		 let(:user) { build(:user) }
			def mock_user(stubs={})
        @mock_user ||= mock_model(Spree::User, stubs).as_null_object
    end
    before(:each) do
       
        request.env['warden'] = mock(Warden, :authenticate => mock_user,:authenticate! => mock_user)
	
				@current_user = 1
			end
			  it "should be successful" do
			post :create,{:user=>{:email=>"email@spree.com", :password=>"1234564", :password_confirmation=>"1234564"}},:format=>:json
			response.code.should == "201"
		end
		end
		end