require 'spec_helper'

describe Spree::Admin::TaxonomiesController , :type => "controller" do
	
	def mock_user(stubs={})
		@mock_user ||= mock_model(Spree::User, stubs).as_null_object
	end
	
	before(:each) do
			controller.stub!(:check_http_authorization).and_return(true)
		 @taxonomies_new = Spree::Taxonomy.new
		 @taxonomy = Spree::Taxonomy.create(:name => "RailsFactory")
		 request.env['warden'] = mock(Warden, :authenticate => mock_user,:authenticate! => mock_user)
		@current_user = 1
	end
	
	describe "POST create" do
    it "user To create a Taxonomy" do
			post :create, :taxonomy => { :name => "Category" }, :authentication_token => "C_-CfKztV6n0y3O8NTRD" , :format=> :json 
      response.code.should == "201"
    end
  end	
	
	describe "GET index" do
    it "user To list Taxonomies" do
			get :index, :format=>:json
      response.code.should == "200"
    end
  end
	
	describe "POST update" do
    it "user To update a particular Taxonomy" do
			post :update, :id => @taxonomy.id , :taxonomy => { :name => "Sedin" }, :authentication_token => "C_-CfKztV6n0y3O8NTRD" , :format=> :json 
      response.code.should == "201"
    end
  end
	
	
	describe "DELETE destroy" do
    it "user To delete a particular Taxonomy" do
		 delete :destroy, :id => @taxonomy.id, :taxonomy => { :name => "Sedin" }, :authentication_token => "C_-CfKztV6n0y3O8NTRD" , :format=> :json 
		 response.code.should == "200"
		end
  end
	
	end
	
	