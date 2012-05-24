require 'spec_helper' 

describe   Spree::Admin::ShippingMethodsController,:type=>"controller" do
	#include Devise::TestHelpers
	describe " ZonesController" do
	def valid_attributes
		{
		:name=>"sedin 2 way", :zone_id=>"1", :display_on=>"", :calculator_type=>"Spree::Calculator::FlatPercentItemTotal",:shipping_category_id=>"727197546"
}
end
		
			def mock_user(stubs={})
        @mock_user ||= mock_model(Spree::User, stubs).as_null_object
    end
    before(:each) do
				controller.stub!(:check_http_authorization).and_return(true)
				p	pro=Spree::Zone.create(:name=>"railscfactory",:description=>"software concern")
        request.env['warden'] = mock(Warden, :authenticate => mock_user,:authenticate! => mock_user)
				@current_user = 1
			end
		describe "To get the index of the ShippingMethod controller" do
       it "should be successful" do
          get :index,:format=>:json
					 response.code.should == "200"
			 end
			 it "should get the ShippingMethod" do
					store = Spree::ShippingMethod.create! valid_attributes
          get :show, {:id => store.to_param, :format => :json}
          response.code.should == "200"
       end
		   it "should be successful create ShippingMethod" do
			     post :create , :shipping_method => {:name=>"sedin 2 way", :zone_id=>"1", :display_on=>"", :calculator_type=>"Spree::Calculator::FlexiRate"}, :format => :json
			     response.code.should == "201"
		   end
		   it "should be successful create ShippingMethod" do
					store = Spree::ShippingMethod.create! valid_attributes
					 put :update , :id=>store.to_param,:shipping_method => {:name=>"production"}, :format => :json
			     response.code.should == "201"
				 end
			it "should delete the ShippingMethod" do
				  store = Spree::ShippingMethod.create! valid_attributes
      get :destroy, {:id => store.to_param,:format => :json}
      response.code.should == "200"
    end
		  end
			end 
			end	