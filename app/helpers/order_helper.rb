module OrderHelper
  def order_status(order)
    case order.financial_status
    when 'authorized'
      c = 'attention'
      i = '<i class="ico ico-16 ico-auth-expiry"></i>'
    when 'pending'
      c = 'pending'
      i = ''
    when 'success'
      c = 'success'
      i = ''
    when 'complete'
      c = 'complete'
      i = ''
    when 'warning'
      c = 'warning'
      i = ''
    when 'error'
      c = 'error'
      i = ''
    else
      c = ''
      i = ''
    end
    content_tag :span, "#{i} #{order.financial_status}", :class => "label success #{c}"
  end
  
  def fulfillment_status(order)
    case order.fulfillment_status
      when 'partial'
        s = 'partial'
        c = 'attention'
      when 'warning'
        s = 'warning'
        c = 'warning'
      when 'shipped'
        s = 'fulfilled'
        c = 'fulfilled'
      else
        s = 'not fulfilled'
        c = 'warning'
    end
    content_tag :span, "#{s}", :class => "label #{c}"
  end
end
