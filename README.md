THIS README IS FOR THE SPREE-1-1 BRANCH OF SPREE-API 

## Summary

spree_custom_api is a complete open source e-commerce solution built with Ruby on Rails. It was originally developed by RailsFactory Team.

spree_custom_api  actually consists of list of api's for Spree Version 1.1.0. The list of available api's can be known from the spree_custom_api documentation.
 
Url:- http://spree-apidoc.heroku.com

Http Authentications for viewing the documentation:-

    username : apidoc
    password : d0capi


## Installation Steps:-

1. Add the gem to the gem file

        gem "spree_custom_api", :git=>'git@github.com:railsfactory/spree-api.git'

2. `bundle install`

3. Create a new migration in sandbox
      
      $ rails generate migration AddApiToOrders 

       class AddApiToOrders < ActiveRecord::Migration
         def self.up
           add_column :spree_orders, :api, :boolean,:default => 0
         end

         def self.down
           remove_column :spree_orders, :api, :boolean
         end
       end

4. `rake db:migrate`

5. Changes in spree core:-
 
   Go to spree core/lib/spree/core/current_order.rb

   Replace the method "current_order" with 


        def current_order(create_order_if_necessary = false,auth=nil)
          if !params[:format].nil? && params[:format] == "json" 
            if@current_order.nil?
              @current_order = Spree::Order.new
              user=Spree::User.find_by_authentication_token(auth)
              @current_order.email = user.email
              @current_order.user_id=user.id
              @current_order.api=1
              @current_order.save()
              return @current_order
            else
              user=Spree::User.find_by_authentication_token(auth)
              @current_order = Order.find_by_user_id(user.id)
            end
          else
            return @current_order if @current_order
            if session[:order_id]
              @current_order = Spree::Order.find_by_id(session[:order_id], :include => :adjustments)
            end
            if create_order_if_necessary and (@current_order.nil? or @current_order.completed?)
              @current_order = Spree::Order.new
              before_save_new_order
              @current_order.save!
              after_save_new_order
            end
            session[:order_id] = @current_order ? @current_order.id : nil
            @current_order
          end
        end@current_order if @current_order
          if session[:order_id]
            @current_order = Spree::Order.find_by_id(session[:order_id], :include => :adjustments)
          end
          if create_order_if_necessary and (@current_order.nil? or @current_order.completed?)
            @current_order = Spree::Order.new
            before_save_new_order
            @current_order.save!
            after_save_new_order
          end
          session[:order_id] = @current_order ? @current_order.id : nil
          @current_order
        end
