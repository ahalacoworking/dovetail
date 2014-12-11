module ApplicationHelper

  # Return a string suitable for displaying a CC as last 4 digis
  def last_four(digits)
    cc_string = ""
    (0..2).each do 
      cc_string += "**** "
    end
    cc_string += digits
  end

  def flash_class(level)    
    case level.to_sym
      when :notice then "alert alert-info"
      when :success then "alert alert-success"
      when :error then "alert alert-error"
      when :alert then "alert alert-error"
    end
  end

  def fmt_date(timestamp)
    Time.at(timestamp.to_i).utc.to_datetime.strftime("%B %d, %Y")
  end

  def fmt_amount(amount)
    dollars = amount.to_i / 100
    cents = amount.to_i % 100
    sprintf("$%d.%02d", dollars, cents)
  end

  def active_tab(controller)
    if controller.is_a?(Array)
      if controller.include?(controller_name)
        return "active"
      else
        return ""
      end
    else
      if controller_name == controller
        return "active"
      else
        return ""
      end
    end
  end

  def select_sub_nav
    if ["spaces"].include? controller_name
      if action_name == "new"
        return "shared/user_account"
      else
        return "shared/settings"
      end      
    elsif ["admins", "locations", "resources", "plans", "integrations", "stripes"].include? controller_name
      return "shared/settings"
    elsif ["payment_methods", "registrations", "passwords"].include? controller_name
      return "shared/user_account"
    end
  end

  def field_errors(obj, field)
    msg = nil
    # To get all errors associated with a single attribute, do the following:
    if !obj.errors[field].blank?
      errors = obj.errors[field]
      if errors.kind_of?(Array)
        msg = errors.join(", ")
      else
        msg = name_errors
      end
    end

    unless msg.blank?
      return "<span class='help-block'>#{msg}</span>".html_safe
    else
      return ""
    end
  end

  def has_error(obj, field)
    if !obj.errors[field].blank?
      return "has-error" 
    else
      return ""
    end
  end

  def admin_relationship(admin, space)
    relationships = []

    relationships << "you" if admin.id == current_user.id
    relationships << "owner" if admin.id == space.user_id

    unless relationships.empty?
      "(#{relationships.join(", ")})"
    else
      ""
    end
  end

  def ledger_item_link(space, member, item)
    return space_member_invoice_path(space, member, item) if item.is_invoice
    return space_member_payment_path(space, member, item) if item.is_payment
    return space_member_credit_note_path(space, member, item) if item.is_credit_note
  end

  def item_type_description(item)
    return "Invoice" if item.is_invoice && !(item.status == "open")
    return "Charges" if item.is_invoice && item.status == "open"
    return "Payment" if item.is_payment
    return "Credit" if item.is_credit_note
  end

  def paid(item)
    if item.is_invoice
      return (item.paid? ? "Paid" : payment_link(item))
    else
      return ""
    end
  end

  def payment_link(item)
    raise "Can only pay invoices" unless item.is_invoice
    raise "Can only pay unpaid invoices" if item.paid?

    link_to("Make payment", "/#{item.id}/makepayment", method: :post)
  end

  ThirdPartyApp = Struct.new(:impl, :label, :path, :icon, :description)

  def integrations(space)
    [
     ThirdPartyApp.new("StripeIntegration", "Stripe", 
                       space_integrations_stripe_path(space), 
                       "stripe.png", 
                       "Get paid using your Stripe account."),

     # ThirdPartyApp.new("MailchimpIntegration", "Mailchimp", 
     #                   integrations_mailchimp_path,
     #                   "mailchimp.png", 
     #                   "Automatically add members to your mailing list(s)."),     
    ]
  end

end
