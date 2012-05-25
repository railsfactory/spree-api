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
		request.env["devise.mapping"] = Devise.mappings[:user]
		@current_user = 1
		controller.stub!(:associate_user).and_return(true)
	end
	
	describe "POST create" do
		it "should create the user successful" do
			p @user=Spree::User.create(:email => "email123@person.com", :password => "secret", :password_confirmation => "secret")
			@auth=@user.authentication_token="16qL-TsdhrJmHGWCC8bS"
			@user.save
		 post :create,  :user=>{:email => "email@person.com", :password => "secret", :password_confirmation => "secret"} , :format=>:json
		response.code.should == "200"
	end
	it "should not create the user" do
			#~ p @user=Spree::User.create(:email => "email123as@person.com", :password => "secret", :password_confirmation => "secret")
			#~ @auth=@user.authentication_token="16qL-TsdhrJmHGWCC8bS"
			#~ @user.save
			post :create
		#~ controller.stub!(:render_with_scope).and_return(true)
		response.code.should == "200"
	end
	
end

		end
		end