require 'spec_helper.rb'

describe Spree::Admin::ProductsController , :type => "controller" do
	
	 def mock_user(stubs={})
					@mock_user ||= mock_model(Spree::User, stubs).as_null_object
	end
				
		
	before(:each) do
			controller.stub!(:check_json_authenticity).and_return(true)		
		  @product = Spree::Product.create(:id => 1,:name => "product1" ,:description => "product1 description",:price => 123)
			 request.env['warden'] = mock(Warden, :authenticate => mock_user,:authenticate! => mock_user)
			 @current_user = 1
	 end


		describe "POST create" do
			it "user To create a product" do
				post :create , {:format => "json"}
				@product1 = Spree::Product.create!(:id => 2,:name => "product2" ,:description => "product2 description",:price => 123)
				response.should be_success
		   end
  end	

	describe "GET show" do
    it "user To display particular product" do
			get :show,{:id=>@product.id , :format => :json}
			assigns(:object).should eq(@product)
			response.should be_success
    end
  end
	
		describe "PUT update" do
    it "user To update a product" do
			put :update, {:format=>:json , :object_name => "Product3"}
				response.should be_success
    end
  end	
	
	describe "DELETE destroy" do
    it "user To delete a product" do
			delete :destroy, {:id => @product.id,:format=>:json}
			response.should be_success
    end
  end	
	
end