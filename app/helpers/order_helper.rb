module OrderHelper
  def order_status(order)
    case order.financial_status
    when 'authorized'
      c = 'authorized success'
      i = ''
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
    when 'paid'
      c = 'complete'
      i = ''
    else
      c = ''
      i = ''
    end
    content_tag :span, "#{i} #{order.financial_status}", :class => "label #{c}"
  end
  
  def fulfillment_status(order)
    case order.fulfillment_status
      when 'partial'
        s = 'partial'
        c = 'attention'
      when 'warning'
        s = 'warning'
        c = 'warning'
      when 'complete'
        s = 'fulfilled'
        c = 'complete'
      when 'fulfilled'
        s = 'fulfilled'
        c = 'complete'
      else
        s = 'not fulfilled'
        c = 'warning'
    end
    content_tag :span, "#{s}", :class => "label #{c}"
  end
end
