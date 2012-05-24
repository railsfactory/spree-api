require 'spec_helper'

describe Spree::Admin::PaymentMethodsController , :type => "controller" do
  
  def mock_user(stubs={})
    @mock_user ||= mock_model(Spree::User, stubs).as_null_object
  end
  
  before(:each) do
    controller.stub!(:check_http_authorization).and_return(true)
    @payment_method_new = Spree::PaymentMethod.new
    @payment_method = Spree::PaymentMethod.create(:name => "sedin" , :description => "sedin gateway" , :display_on=>"", :active=>"true")
    request.env['warden'] = mock(Warden, :authenticate => mock_user,:authenticate! => mock_user)
    @current_user = 1
  end
  
  describe "GET new" do
    it "assign the new paymentmethod" do
      get :new, :format=> :json
      assigns(:object).should be_a_new(Spree::PaymentMethod)
    end
  end
  
  describe "GET index" do
    it "user To list paymentmethod units" do
      get :index, :format=>:json
      response.code.should == "200"
    end
  end
  
  describe "GET show" do
    it "user To display particular Payment method" do
      get :show,{:id => @payment_method.id , :format => :json}
      response.should be_success
    end
    it "user To display particular Payment method with wrong id" do
      get :show,{:id => 20}
      response.code.should == "302"
    end
  end
  
  describe "POST create" do
    it "user To create a OptionTypes" do
      post :create, :option_type => { :name => "option_test" , :presentation => "presentation_test" }, :authentication_token => "HItfNtYHxehwpBQ3WO4k" , :format=> :json
      response.code.should == "200"
    end
  end	
  
  describe "POST update" do
    it "user To update a particular OptionType" do
      put :update, :id => @payment_method.id , :option_type => { :name => "option_test_update" , :presentation => "presentation_test_update" }, :authentication_token => "HItfNtYHxehwpBQ3WO4k" , :format=>:json
      response.code.should == "200"
    end
    it "user To update a particular OptionType with wrong id" do
      put :update, :id => 20, :option_type => { :name => "option_test_update" , :presentation => "presentation_test_update" }, :authentication_token => "HItfNtYHxehwpBQ3WO4k" 
      response.code.should == "302"
    end
  end	
  
  describe "DELETE destroy" do
    it "user To delete a particular OptionType" do
      delete :destroy, :id => @payment_method.id, :authentication_token => "C_-CfKztV6n0y3O8NTRD",:format=>:json
      response.code.should == "200"
    end
    it "user To delete a particular OptionType with wrong id" do
      delete :destroy, :id => 20, :authentication_token => "C_-CfKztV6n0y3O8NTRD"
      response.code.should == "302"
    end
  end	
  
end
