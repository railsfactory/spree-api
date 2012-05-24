require 'spec_helper' 

describe   Spree::Admin::MailMethodsController,:type=>"controller" do
	#include Devise::TestHelpers
	describe " MailMethodsController" do
	def valid_attributes
		{
		:environment=>"railsfactory"
    }
   		end
		
			def mock_user(stubs={})
        @mock_user ||= mock_model(Spree::User, stubs).as_null_object
    end
    before(:each) do
				controller.stub!(:check_http_authorization).and_return(true)
        request.env['warden'] = mock(Warden, :authenticate => mock_user,:authenticate! => mock_user)
				@current_user = 1
			end
		describe "To get the index of the products controller" do
       it "should be successful" do
          get :index,:format=>:json
					 response.code.should == "200"
			 end
			 it "should get the products" do
					store = Spree::MailMethod.create! valid_attributes
          get :show, {:id => store.to_param, :format => :json}
          response.code.should == "200"
       end
		   it "should be successful create mail_method" do
			     post :create , :mail_method => {:environment=>"development"}, :format => :json
			     response.code.should == "201"
		   end
		   it "should be successful create mail_method" do
					store = Spree::MailMethod.create! valid_attributes
					 put :update , :id=>store.to_param,:mail_method => {:environment=>"production"}, :format => :json
			     response.code.should == "201"
				 end
			it "should delete the mail_method" do
				  store = Spree::MailMethod.create! valid_attributes
      get :destroy, {:id => store.to_param,:format => :json}
      response.code.should == "200"
    end
		  end
			end 
			end	