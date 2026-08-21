# app/helpers/payments_helper.rb
module PaymentsHelper
  def payment_method_badge(payment)
    method = payment.payment_method
    colors = {
      "cash" => "bg-green-100 text-green-800",
      "transfer" => "bg-blue-100 text-blue-800",
      "card" => "bg-purple-100 text-purple-800",
      "mp" => "bg-sky-100 text-sky-800",
      "link" => "bg-amber-100 text-amber-800"
    }

    content_tag(:span,
      payment.payment_method_name,
      class: "px-2 py-1 text-xs font-medium rounded-full #{colors[method]}"
    )
  end

  def payment_method_icon(payment)
    icons = {
      "cash" => "💰",
      "transfer" => "🏦",
      "card" => "💳",
      "mp" => "🟦",
      "link" => "🔗"
    }
    icons[payment.payment_method] || "💵"
  end
end
