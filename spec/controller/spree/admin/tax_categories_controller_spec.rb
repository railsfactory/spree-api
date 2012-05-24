require 'spec_helper'

describe Spree::Admin::TaxCategoriesController , :type => "controller" do
	
	def mock_user(stubs={})
		@mock_user ||= mock_model(Spree::User, stubs).as_null_object
	end
	
	before(:each) do
			controller.stub!(:check_http_authorization).and_return(true)
		 @tax_category = Spree::TaxCategory.create(:name => "taxCategory1 name" , :description => "taxCategory1 description" , :is_default => true)
		 request.env['warden'] = mock(Warden, :authenticate => mock_user,:authenticate! => mock_user)
		@current_user = 1
	end
		
	
	describe "GET index" do
    it "user To list TaxCategories units" do
			get :index, :format=>:json
      response.code.should == "200"
    end
  end
	
	describe "GET show" do
    it "user To display particular TaxCategory" do
			get :show, { :id=>@tax_category.id , :format=>:json }
			response.should be_success
    end
  end
	
	describe "POST create" do
    it "user To create a TaxCategory" do
			post :create, :tax_category => { :name => "TaxCategoryName_test_create" , :description => "TaxCategoryDescription_test_create" , :is_default => 1 } , :format=>:json 
      response.code.should == "201"
    end
  end	
	
	describe "PUT update" do
    it "user To update a TaxCategory" do
			put :update, :id => @tax_category.id , :tax_category => { :name => "TaxCategoryName_test_update" , :description => "TaxCategoryDescription_test_update" , :is_default => 1 } , :format=>:json 
      response.code.should == "201"
    end
  end	
	
	describe "DELETE destroy" do
    it "user To delete a TaxCategory" do
			delete :destroy,  { :id => @tax_category.id , :format=>:json }
			response.code.should == "200"
    end
  end	
	
	end