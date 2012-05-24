require 'spec_helper' 

describe   Spree::OrdersController,:type=>"controller" do
	#include Devise::TestHelpers
	describe " OrdersController" do
	
			def mock_user(stubs={})
        @mock_user ||= mock_model(Spree::User, stubs).as_null_object
    end
    before(:each) do
       
        request.env['warden'] = mock(Warden, :authenticate => mock_user,:authenticate! => mock_user)
	
				@current_user = 1
			end
			 it "should get before_filtered for authenticate_jobseeker!" do
			controller.stub!(:check_http_authorization).and_return(true)
		end
		it "should be successful" do
		#user = create(:user, :email => "email@person.com", :password => "secret", :password_confirmation => "secret")
		   order=Spree::Order.last
			 pro=Spree::Product.create(:name=>"railscfactory",:description=>"software concern",:price =>19.99,:cost_price=>17.00,:sku=> "ABC")
			var=Spree::Variant.create(:sku=>"top size", :price=>19.99, :cost_price=>17.00,:weight=>12, :height=>96, :width=>36, :depth=>"",:product_id=>1)
			put :update,{:line_item=>{:variant_id=>var.to_param,:quantity=>3},:id=>order.to_param,:format=>:json}
			response.code.should == "200"
		end
		
			describe "To get the index of the products controller" do
    it "should be successful" do
       get :index,:format=>:json
               response.code.should == "200"
					end
		it "should get the products" do
      get :show, :format => :json
      response.code.should == "200"
    end
		#~ it "should delete the products" do
						  #~ store = Spree::Product.create! valid_attributes
      #~ get :destroy, {:id => store.to_param}, :format => :json
      #~ response.code.should == "200"
    #~ end
    end

			end 
			end	