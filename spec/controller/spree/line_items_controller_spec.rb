require 'spec_helper' 

describe   Spree::LineItemsController,:type=>"controller" do
	#include Devise::TestHelpers
	describe " LineItemsController" do
		 let(:user) { build(:user) }
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
			describe "To get the index of the products controller" do
    it "should be successful" do
		#user = create(:user, :email => "email@person.com", :password => "secret", :password_confirmation => "secret")
			pro=Spree::Product.create(:name=>"railscfactory",:description=>"software concern",:price =>19.99,:cost_price=>17.00,:sku=> "ABC")

			var=Spree::Variant.create(:sku=>"top size", :price=>19.99, :cost_price=>17.00,:weight=>12, :height=>96, :width=>36, :depth=>"",:product_id=>1)
			post :create,{:line_item=>{:variant_id=>var.to_param,:quantity=>3},:authentication_token=>"16qL-TsdhrJmHGWCC8bS"},:format=>:json
			response.code.should == "201"
		end
		end
		#~ it "should get the products" do
						  #~ store = Spree::Product.create! valid_attributes
      #~ get :show, {:id => store.to_param}, :format => :json
      #~ response.code.should == "200"
    #~ end
		#~ it "should delete the products" do
						  #~ store = Spree::Product.create! valid_attributes
      #~ get :destroy, {:id => store.to_param}, :format => :json
      #~ response.code.should == "200"
    #~ end
		#~ end
			end 
			end	