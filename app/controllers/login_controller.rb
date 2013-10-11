class LoginController < ApplicationController

  def byebye
    render :file => "#{RAILS_ROOT}/public/index.html"
  end

  def index
    # don't ask user for his #{shop}.myshopify.com address if it is already provided
    redirect_to :controller => 'login', :action => "authenticate", :shop => params[:shop] if params[:shop].present?
  end


  def authenticate
    if params[:shop].blank?
      flash[:error] = "You entered a blank domain, please try again."
      redirect_to(:back)
    else
      if Shop.find_by_url(myshopify_url(params[:shop]))
        session.delete :new_user
        redirect_to ShopifyAPI::Session.new(params[:shop]).create_permission_url
      else
        block_new_shop
      end
    end
  end

  # Shopify redirects the logged-in user back to this action along with
  # the authorization token t.
  #
  # This token is later combined with the developer's shared secret to form
  # the password used to call API methods.
  def finalize
    shopify_session = ShopifyAPI::Session.new(params[:shop], params[:t])
    if shopify_session.valid?
      session[:shopify] = shopify_session

      if Shop.find_by_url(shopify_session.url)
        session.delete :new_user
        flash[:notice] = "Successfully logged into shopify store."
        redirect_to session.delete(:return_to) || '/orders'
      else
        block_new_shop
      end
    else
      flash[:error] = "Could not log into Shopify store."
      redirect_to :action => 'index'
    end
  end

  def logout
    session[:shopify] = nil
    flash[:notice] = "Successfully logged out."

    redirect_to :action => 'index'
  end

  private

  def myshopify_url(url)
    if url =~ /\w+\.myshopify\.com\z/
      url
    else
      "#{url}.myshopify.com"
    end
  end

  def block_new_shop
    flash[:error] = "PixelPrinter has been deprecated. Please <a href='http://apps.shopify.com/order-printer'>install Order Printer</a> instead."
    session[:new_user] = true
    redirect_to :action => 'index'
  end
end
