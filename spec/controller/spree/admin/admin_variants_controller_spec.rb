require 'spec_helper.rb'

describe Spree::Admin::VariantsController , :type => "controller" do
		
	def mock_user(stubs={})
		@mock_user ||= mock_model(Spree::User, stubs).as_null_object
	end
				
		
	before(:each) do
			controller.stub!(:check_http_authorization).and_return(true)		
			controller.stub!(:invoke_callbacks).and_return(true)		
		@product = Spree::Product.create(:name=>"railscfactory",:description=>"software concern",:price =>19.99,:cost_price=>17.00,:sku=> "ABC")
		@variant = Spree::Variant.create(:sku=>"top size", :price=>19.99, :cost_price=>17.00,:weight=>12, :height=>96, :width=>36, :depth=>"",:product_id=>1)
			request.env['warden'] = mock(Warden, :authenticate => mock_user,:authenticate! => mock_user)
			@current_user = 1
	 end

	
	describe "GET index" do
    it "user To list Variants" do
			get :index, :format=>:json
				response.code.should == "200"
    end
  end
		

	describe "GET show" do
    it "user To display particular variant" do
			get :show,{:id=>@variant.id , :format=>:json }
			response.should be_success
    end
  end
	
		describe "POST create" do
			it "user To create a variant" do
				post :create, {:variant => {:sku=>"variant_test_create", :price=>19.99, :on_hand => 45 ,:cost_price=>17.00,:weight=>12, :height=>96, :width=>36, :depth=>"",:product_id=>1 } , :format=>:json }
				response.code.should == "201"
			end
		end	
		
    describe "PUT UPDATE" do 
		  it "User To update the variant" do
				put :update ,:id => @variant.id ,:variant => {:sku=>"variant_test_update", :price=>19.99, :on_hand => 45 ,:cost_price=>17.00,:weight=>12, :height=>96, :width=>36, :depth=>"",:product_id=>1 } , :format=>:json 
			  response.code.should == "201"
		end
	end
	
		describe "DELETE destroy" do  
			it "user To display particular variant" do
				delete :destroy,{:id => @variant.id ,:format=>:json }
				response.should be_success
			end
		end
			
		
end