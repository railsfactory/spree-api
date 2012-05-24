require 'spec_helper' 

describe   Spree::ProductsController,:type=>"controller" do
	#include Devise::TestHelpers
	describe " ProductsController" do
	def valid_attributes
		{
		:name=>"railscfactory",
    :description=>"software concern",
    :price =>19.99,
    :cost_price=>17.00,
    :sku=> "ABC"}
   		end
		
			def mock_user(stubs={})
        @mock_user ||= mock_model(Spree::User, stubs).as_null_object
    end
    before(:each) do
       controller.stub!(:check_http_authorization).and_return(true)
        request.env['warden'] = mock(Warden, :authenticate => mock_user,:authenticate! => mock_user)
	
				@current_user = 1
			end
			 it "should get before_filtered for authenticate_jobseeker!" do
			controller.stub!(:check_http_authorization).and_return(true)
		end
			describe "To get the index of the products controller" do
    it "should be successful" do
       get :index,:format=>:json
				response.code.should == "200"
					end
		it "should get the products" do
						  store = Spree::Product.create! valid_attributes
      get :show, {:id => store.to_param}, :format => :json
      response.code.should == "200"
    end
		it "should delete the products" do
						  store = Spree::Product.create! valid_attributes
      get :destroy, {:id => store.to_param}, :format => :json
      response.code.should == "200"
    end
		end
			end 
			end	