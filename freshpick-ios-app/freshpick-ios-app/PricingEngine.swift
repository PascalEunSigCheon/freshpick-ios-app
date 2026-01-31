import Foundation

enum FulfillmentMethod: String, Codable {
    case pickup, delivery
}

struct PriceBreakdown {
    var itemsTotal: Double
    var deliveryFee: Double
    var serviceFee: Double
    var smallOrderFee: Double
    var tax: Double
    var tip: Double
    var grandTotal: Double
}

struct PricingEngine {
    static func calculate(itemsTotal: Double, fulfillment: FulfillmentMethod, tipPercent: Double, taxRate: Double) -> PriceBreakdown {
        let serviceFee = itemsTotal > 0 ? 2.50 : 0.0
        let deliveryFee = fulfillment == .delivery ? 5.99 : 0.0
        let smallOrderFee = (itemsTotal > 0 && itemsTotal < 15) ? 1.99 : 0.0
        let tax = taxRate * itemsTotal
        let tip = tipPercent * itemsTotal
        let grandTotal = itemsTotal + deliveryFee + serviceFee + smallOrderFee + tax + tip
        return PriceBreakdown(
            itemsTotal: itemsTotal,
            deliveryFee: deliveryFee,
            serviceFee: serviceFee,
            smallOrderFee: smallOrderFee,
            tax: tax,
            tip: tip,
            grandTotal: grandTotal
        )
    }
}
