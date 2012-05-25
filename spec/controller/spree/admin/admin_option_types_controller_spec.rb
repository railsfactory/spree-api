require 'spec_helper'

describe Spree::Admin::OptionTypesController , :type => "controller" do
  
  def mock_user(stubs={})
    @mock_user ||= mock_model(Spree::User, stubs).as_null_object
  end
  
  
  before(:each) do
    controller.stub!(:check_http_authorization).and_return(true)
    @option_type_new = Spree::OptionType.new
    @option_type = Spree::OptionType.create(:name => "Option Type 1" , :presentation => "Presentation 1" )
    request.env['warden'] = mock(Warden, :authenticate => mock_user,:authenticate! => mock_user)
    @current_user = 1
  end
  

  describe "GET index" do
    it "user To list OptionTypes units" do
      get :index, :format=>:json
      response.code.should == "200"
    end
    
    it "user To list OptionTypes units with wrong value" do
      get :index, {}, :format=>:json
      response.code.should == "200"
    end
  end

  
  describe "GET show" do
    it "user To display particular Option Type" do
      get :show,{:id => @option_type.id , :format => :json}
      response.should be_success
    end
    it "user To display particular Option Type with wrong value" do
      get :show,{:id => 20 , :format => :json}
      p response.code.should == "200"
    end
  end
  
  describe "POST create" do
    it "user To create a OptionTypes" do
      post :create, :option_type => { :name => "option_test" , :presentation => "presentation_test" }, :authentication_token => "HItfNtYHxehwpBQ3WO4k" , :format=> :json
      response.code.should == "201"
    end
    it "user To create a OptionTypes with wrong paramater value" do
      post :create, :option_type => { :name => "option_test" , :presentation => "presentation_test" }, :authentication_token => "HItfNtYHxehwpBQ3WO4k" 
      response.code.should == "302"
    end
  end	
  
  describe "POST update" do
    it "user To update a particular OptionType" do
      put :update, :id => @option_type.id , :option_type => { :name => "option_test_update" , :presentation => "presentation_test_update" }, :authentication_token => "HItfNtYHxehwpBQ3WO4k" , :format=>:json
      response.code.should == "201"
    end
    it "user To update a particular OptionType with wrong id value" do
      put :update, :id =>20 , :option_type => { :name => "option_test_update" , :presentation => "presentation_test_update" }, :authentication_token => "HItfNtYHxehwpBQ3WO4k" , :format=>:json
      response.code.should == "200"
    end
  end	
  
  describe "DELETE destroy" do
    it "user To delete a particular OptionType" do
      delete :destroy, :id => @option_type.id, :authentication_token => "C_-CfKztV6n0y3O8NTRD",:format=>:json
      response.code.should == "200"
    end
    it "user To delete a particular OptionType with wrong id value" do
      delete :destroy, :id => 20, :authentication_token => "C_-CfKztV6n0y3O8NTRD",:format=>:json
      response.code.should == "200"
    end
  end	
  
end
