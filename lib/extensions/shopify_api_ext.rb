module ShopifyAPI
  module PriceConversion
    def to_cents(amount)
      (amount.to_f * 100).round
    end  
  end

  
  class Shop < Base
    cattr_accessor :cached
    
    def to_liquid
      {
        'name'     => name,
        'email'    => email,
        'address'  => address1,
        'city'     => city,
        'zip'      => zip,
        'country'  => country,
        'phone'    => phone,
        'province' => province,
        'owner'    => shop_owner
      }
    end
  end               

  class Address < Base
    def to_liquid
      address_hash = Hash.from_xml(to_xml)
      # is either shipping address or billing address
      address_hash[address_hash.keys.first].merge('street' => street)
    end
    
    def street
      string = address1
      string += " #{address2}" if address2
      string
    end
  end
  
  class ShippingAddress < Address
  end

  class BillingAddress < Address
  end         

  class Order < Base
    include OrderCalculations
    include PriceConversion
    
    def self.lookup(id)
      Rails.cache.fetch("orders/#{id}", :expires_in => 1.hour) do
        find(id)
      end
    end

    def shipping_line
      case shipping_lines.size
      when 0
        nil
      when 1
        shipping_lines.first
      else
        title = shipping_lines.collect(&:title).to_sentence
        price = shipping_lines.to_ary.sum(&:price)
        {:title => title, :price => to_cents(price)}
      end
    end
          
    def to_liquid
      fulfilled, unfulfilled = line_items.partition {|item| item.fulfilled?}
      shop = Shop.cached
      { 
        'id'                => id,
        'created_at'        => created_at.in_time_zone,
        'name'              => name, 
        'email'             => email,
        'gateway'           => gateway,
        'order_name'        => name, 
        'order_number'      => number, 
        'shop_name'         => shop.name,
        'subtotal_price'    => to_cents(subtotal_price),
        'total_price'       => to_cents(total_price),
        'tax_price'         => to_cents(total_tax),
        'tax_lines'         => tax_lines,
        'shipping_price'    => shipping_price,
        'shipping_address'  => shipping_address,
        'billing_address'   => billing_address, 
        'line_items'        => line_items,
        'fulfilled_line_items' => fulfilled,
        'unfulfilled_line_items' => unfulfilled,
        'shipping_methods'  => shipping_lines,
        'shipping_method'   => shipping_line,
        'note'              => note,
        'attributes'        => note_attributes, 
        'customer'          => {'email' => email, 'name' => billing_address.name},
        'shop'              => shop.to_liquid,
        'total_discounts'   => to_cents(total_discounts),
        'financial_status'  => financial_status,
        'fulfillment_status' => fulfillment_status,
        'payment_details'   => payment_details,
        'credit_card'       => payment_details,  # keep credit_card for legacy reasons because it was named like that intially on the shopify side
        'discounts'         => discounts,
        'discounts_savings' => discounts.present? && discounts.first.savings,
        'discounts_amount'  => discounts.present? && discounts.first.amount
      }
    end    
    
    
    private
    
    def shipping_address
      attributes['shipping_address']
    end
    
    def shipping_price
      shipping_line && to_cents(shipping_line.price)
    end
    
    def note_attributes
      [attributes['note_attributes']].flatten.inject({}) do |memo, attr|
        memo[attr.name] = attr.value
        memo
      end
    end
    
    def payment_details
      details = attributes['payment_details']
      number  = details && details.credit_card_number
      company = details && details.credit_card_company
      {
        'number' => number,
        'credit_card_number' => number,
        'company' => company,
        'credit_card_company' => company
      }
    end

    def discounts
      return nil if discount_codes.empty?

      discount_codes.map do |discount_code|
        Discount.new(discount_code.attributes)
      end
    end

    def line_items
      items = super
      items.each do |item|
        item.order_id = self.id
      end
      items
    end

    class Discount < Base
      include PriceConversion

      def savings
        amount.to_f * -1
      end

      def to_liquid
        {
          'amount' => to_cents(amount),
          'savings' => to_cents(savings),
          'code' => code,
          'title' => code
        }
      end
    end
  end

  class LineItem < Base
    include PriceConversion

    def to_liquid
      {
        'id'         => id, 
        'title'      => name, 
        'price'      => to_cents(price), 
        'line_price' => (to_cents(price) * quantity), 
        'quantity'   => quantity,
        'sku'        => sku,
        'grams'      => grams,
        'vendor'     => vendor,
        'variant_id' => variant_id,
        'variant'    => lambda { variant },
        'product'    => lambda { product },
        'fulfillment'=> lambda { last_successful_fulfillment },
        'properties' => line_item_properties
      }
    end
    
    def variant
      @variant ||= Variant.lookup(variant_id, product_id)
    end
    
    def product
      @product ||= Product.lookup(product_id)
    end
    
    def order
      @order   ||= Order.lookup(order_id)
    end

    def fulfilled?
      fulfillment_status == 'fulfilled'
    end

    def last_successful_fulfillment
      @fulfillment ||= begin
        sorted_fulfillments = order.fulfillments.sort{|a, b| b.created_at <=> a.created_at}
        sorted_fulfillments.find do |fulfillment|
          fulfillment.line_items.any?{|item| item.variant_id == self.variant_id }
        end
      end
    end

    def line_item_properties
      return properties if properties.first.is_a?(Array)

      properties.map do |properties_array|
        [properties_array.name, properties_array.value]
      end
    end
  end       


  class Product < Base
    def self.lookup(id)
      Rails.cache.fetch("products/#{id}", :expires_in => 1.hour) do
        find(id)
      end
    end
    
    def to_liquid
      {
        'id'                      => id,
        'title'                   => title,
        'handle'                  => handle,
        'content'                 => body_html,
        'description'             => body_html,
        'vendor'                  => vendor,
        'type'                    => product_type,
        'variants'                => variants.collect(&:to_liquid), 
        'images'                  => images.collect(&:to_liquid),
        'featured_image'          => images.first,
        'tags'                    => all_tags,
        'price'                   => price_range,
        'url'                     => "/products/#{handle}",
        'options'                 => options.collect(&:name)
      }
    end
    
    def all_tags
      tags.blank? ? [] : tags.split(",").collect(&:strip)
    end    
  end
  
  class Image < Base
    def to_liquid      
      src.match(/\/(products\/.*)\?/)[0]
    end
  end
  
  
  class Variant < Base
    include PriceConversion
    
    def self.lookup(id, product_id)
      Rails.cache.fetch("products/#{product_id}/variants/#{id}", :expires_in => 1.hour) do
        find(id, {:params => {:product_id => product_id}})
      end
    end

    # truncated (as opposed to Shopify's model) for simplicity
    def to_liquid
      { 
        'id'                 => id, 
        'title'              => title,
        'option1'            => option1,
        'option2'            => option2,
        'option3'            => option3,
        'price'              => to_cents(price), 
        'weight'             => grams, 
        'compare_at_price'   => to_cents(compare_at_price), 
        'inventory_quantity' => inventory_quantity, 
        'sku'                => sku 
      }
    end
  end


  class ShippingLine < Base
    include PriceConversion

    def to_liquid
      {'title' => title, 'price' => to_cents(price)}
    end
  end

  
  class TaxLine < Base
     include PriceConversion
     
     def to_liquid
       {
         'price'     => to_cents(price), 
         'rate'      => rate, 
         'title'     => title
       }
     end
   end  
  
  class Fulfillment < Base
    def to_liquid
      {
        'tracking_number'   => tracking_number,
        'tracking_company'  => tracking_company,
        'created_at'        => created_at
        #'tracking_url'      => tracking_url
      }
    end
  end

  # TODO: remove this, and see if Heroku still can't find ShopifyAPI::Product::Option (it worked locally somehow with adding theclass)
  class Product < Base
    class Option < Base
      def to_liquid
        name
      end
      
      def to_s
        name
      end   
    end
  end
end