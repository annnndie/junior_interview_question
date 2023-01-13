require './models/campaign.rb'
require './models/order.rb'

# 計算規則
#
# 1. 消費未滿 $1,500, 則須增加 $60 運費
# 2. 若消費期間有超過兩個優惠活動，取最優者折扣 
# 3. 運費計算在優惠折抵之後
#
# Please implemenet the following methods.
# Additional helper methods are recommended.

class PriceCalculation
  FREE_SHIPMENT_PRICE = 1500
  SHIPPING_FEE = 60

  def initialize(order_id)
    @order = Order.find(order_id)
    raise Order::NotFound if @order.nil?
  end

  def total
    @total ||= apply_total_price
  end

  def free_shipment?
    @order.price >= FREE_SHIPMENT_PRICE
  end

  private

  def apply_total_price
    price = calculate_price_with_campaign
    free_shipment? ? price : price + SHIPPING_FEE
  end

  def best_discount_ratio
    @best_discount_ratio ||= Campaign.running_campaigns(@order.order_date).max_by(&:discount_ratio)&.discount_ratio || 0
  end

  def calculate_price_with_campaign
    @order.price * (1 - best_discount_ratio / 100.0) 
  end
end
