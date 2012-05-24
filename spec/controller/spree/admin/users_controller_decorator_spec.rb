require 'spec_helper' 

describe   Spree::Admin::UsersController,:type=>"controller" do
	#include Devise::TestHelpers
	describe " UsersController" do
	def valid_attributes
		{:email=>"ram@gmail.com", :password=>"123456"
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
		describe "To get the index of the Zones controller" do
       it "should be successful" do
          get :index,:format=>:json
					 response.code.should == "200"
			 end
			 it "should get the zone" do
					store = Spree::User.create! valid_attributes
          get :show, {:id => store.to_param, :format => :json}
          response.code.should == "200"
       end
		   it "should be successful create zone" do
			     post :create , :user => {:email=>"raj@gmail.com",:password=>"123456",:confirmation_password=>"123456"}, :format => :json
			     response.code.should == "201"
		   end
		   it "should be successful create zone" do
					store = Spree::User.create! valid_attributes
					 put :update , :id=>store.to_param,:user => {:email=>"raj@gmail.com",:password=>"123456"}, :format => :json
			     response.code.should == "201"
				 end
			it "should delete the zone" do
				  store = Spree::User.create! valid_attributes
      get :destroy, {:id => store.to_param,:format => :json}
      response.code.should == "200"
    end
		  end
			end 
			end	