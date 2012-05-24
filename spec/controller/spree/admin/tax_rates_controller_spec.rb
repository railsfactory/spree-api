require 'spec_helper'

describe Spree::Admin::TaxRatesController , :type => "controller" do
		
	def mock_user(stubs={})
		@mock_user ||= mock_model(Spree::User, stubs).as_null_object
	end
	
	before(:each) do
		controller.stub!(:check_http_authorization).and_return(true)
		@zone = Spree::Zone.create(:name => "zone1-name1" , :description => "zone1-description" , :default_tax => 1)
		@tax_category = Spree::TaxCategory.create(:name => "tax1" , :description => "tax1 description" , :is_default => true)
		@tax_rate = Spree::TaxRate.create(:amount => 100 , :zone_id => @zone.id , :tax_category_id => @tax_category.id ,:included_in_price => true , :calculator_type => "Spree::Calculator::DefaultTax")
		request.env['warden'] = mock(Warden, :authenticate => mock_user,:authenticate! => mock_user)
		@current_user = 1
	 end
	 
		
	describe "GET index" do
    it "user To list TaxCategories units" do
			get :index,  :format => :json 
		  response.code.should == "200"	
    end
  end
	
	describe "GET show" do
    it "user To display particular TaxCategory" do
			get :show,{:id=>@tax_rate.id , :format=>:json }
			response.should be_success
    end
  end
	
	
	describe "POST create" do
    it "user To create a TaxRate" do
			post :create, :tax_rate => { :zone_id => @zone.id , :tax_category_id => @tax_category.id , :amount => 250 , :included_in_price => true , :calculator_type => "Spree::Calculator::DefaultTax"}  ,:format=>:json
      response.code.should == "201"
    end
  end	
	
	
	describe "POST update" do
    it "user To update a TaxRate" do
			put :update, :id => @tax_rate.id , :tax_rate => { :zone_id => @zone.id , :tax_category_id => @tax_category.id , :amount => 1045 , :included_in_price => true , :calculator_type => "Spree::Calculator::DefaultTax"}  ,:format=>:json
      response.code.should == "201"
    end
  end	
	
	describe "DELETE destroy" do
    it "user To delete a TaxCategory" do
			delete :destroy, {:id => @tax_rate.id , :format=>:json }
		  response.code.should == "200"	
    end
  end	
	
end