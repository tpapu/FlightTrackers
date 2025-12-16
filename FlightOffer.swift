import Foundation

struct FlightOffer: Identifiable {
    let id = UUID()
    let cabin: CabinClass
    let totalCost: Decimal
}
