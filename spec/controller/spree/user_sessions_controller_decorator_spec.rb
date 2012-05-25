require 'spec_helper' 

describe   Spree::UserSessionsController,:type=>"controller" do
	#include Devise::TestHelpers
	describe " UserSessionsController" do
		 let(:user) { build(:user) }
			def mock_user(stubs={})
        @mock_user ||= mock_model(Spree::User, stubs).as_null_object
    end
    before(:each) do
        request.env['warden'] = mock(Warden, :authenticate => mock_user)
				request.env["devise.mapping"] = Devise.mappings[:user]
				@current_user = 1
				controller.stub!(:authenticate_user!).and_return(true)
			end
		#~ it "should be successful" do
			#~ @user=Spree::User.create(:email => "email@person.com", :password => "secret", :password_confirmation => "secret")
			#~ @auth=@user.authentication_token="16qL-TsdhrJmHGWCC8bS"
			#~ @user.save
			#~ post :create , :user=>{:email => "email123@person.com", :password => "secret", :password_confirmation => "secret"} , :format => :json
			 #~ response.code.should == "200"
		#~ end
				 
	it "should delete the user" do
		@user=Spree::User.create(:email => "email@person.com", :password => "secret", :password_confirmation => "secret")
					@auth=@user.authentication_token="16qL-TsdhrJmHGWCC8bS"
					@user.save
					get :destroy, {:id => @user.to_param,:format => :json}
				response.code.should == "200"
			end
			
		end
		end