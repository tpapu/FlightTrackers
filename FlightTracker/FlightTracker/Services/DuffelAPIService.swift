//
//  DuffelAPIService.swift
//  FlightTracker
//
//  Service class for interacting with the Duffel API to fetch flight offers.
//  Implements proper error handling and data transformation.
//

import Foundation

/// Service for making requests to the Duffel API
class DuffelAPIService {
    static let shared = DuffelAPIService()
    
    private let apiKey = "duffel_test_nQJcuQAfxqpTTa2r0Rw73CYBq_Qo-jyerBvCSjZHqMn"
    private let baseURL = "https://api.duffel.com"
    private let useTestMode = true // Set to true to use sample data
    
    private init() {}
    
    /// Custom errors for API operations
    enum APIError: LocalizedError {
        case invalidURL
        case networkError(Error)
        case invalidResponse
        case decodingError(Error)
        case apiError(String)
        case unauthorized
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid API URL"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            case .invalidResponse:
                return "Invalid response from server"
            case .decodingError(let error):
                return "Failed to decode response: \(error.localizedDescription)"
            case .apiError(let message):
                return "API error: \(message)"
            case .unauthorized:
                return "Unauthorized: Invalid API key"
            }
        }
    }
    
    /// Search for flight offers
    /// - Parameters:
    ///   - origin: Origin airport IATA code
    ///   - destination: Destination airport IATA code
    ///   - departureDate: Date of departure
    ///   - returnDate: Optional return date for round trips
    ///   - passengers: Number of passengers
    ///   - cabinClass: Preferred cabin class
    /// - Returns: Array of flight offers
    func searchFlights(
        origin: String,
        destination: String,
        departureDate: Date,
        returnDate: Date? = nil,
        passengers: Int = 1,
        cabinClass: Flight.CabinClass = .economy
    ) async throws -> [Flight] {
        // Use sample data in test mode
        if useTestMode {
            print("🧪 Test Mode: Returning sample flight data")
            return generateSampleFlights(
                origin: origin,
                destination: destination,
                departureDate: departureDate,
                passengers: passengers,
                cabinClass: cabinClass
            )
        }
        
        // Create offer request
        let offerRequestId = try await createOfferRequest(
            origin: origin,
            destination: destination,
            departureDate: departureDate,
            returnDate: returnDate,
            passengers: passengers,
            cabinClass: cabinClass
        )
        
        // Fetch offers using the request ID
        return try await fetchOffers(offerRequestId: offerRequestId)
    }
    
    /// Create an offer request in the Duffel API
    private func createOfferRequest(
        origin: String,
        destination: String,
        departureDate: Date,
        returnDate: Date?,
        passengers: Int,
        cabinClass: Flight.CabinClass
    ) async throws -> String {
        guard let url = URL(string: "\(baseURL)/air/offer_requests") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("beta", forHTTPHeaderField: "Duffel-Version")
        request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        
        // Build request body
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate]
        
        var slices: [[String: Any]] = [
            [
                "origin": origin,
                "destination": destination,
                "departure_date": dateFormatter.string(from: departureDate)
            ]
        ]
        
        if let returnDate = returnDate {
            slices.append([
                "origin": destination,
                "destination": origin,
                "departure_date": dateFormatter.string(from: returnDate)
            ])
        }
        
        let passengerArray = (0..<passengers).map { _ in
            ["type": "adult"]
        }
        
        let requestBody: [String: Any] = [
            "data": [
                "slices": slices,
                "passengers": passengerArray,
                "cabin_class": cabinClass.rawValue.lowercased().replacingOccurrences(of: " ", with: "_")
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        // Make the request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if httpResponse.statusCode == 401 {
            throw APIError.unauthorized
        }
        
        guard httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ Duffel API Error:")
            print("Status Code: \(httpResponse.statusCode)")
            print("Response: \(errorMessage)")
            throw APIError.apiError(errorMessage)
        }
        
        // Parse the response to get offer request ID
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let dataDict = json?["data"] as? [String: Any],
              let id = dataDict["id"] as? String else {
            throw APIError.invalidResponse
        }
        
        return id
    }
    
    /// Fetch offers for a given offer request ID
    private func fetchOffers(offerRequestId: String) async throws -> [Flight] {
        guard let url = URL(string: "\(baseURL)/air/offers?offer_request_id=\(offerRequestId)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("beta", forHTTPHeaderField: "Duffel-Version")
        request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw APIError.apiError(errorMessage)
        }
        
        // Parse and transform offers to Flight objects
        return try parseOffersResponse(data)
    }
    
    /// Parse the Duffel API response into Flight objects
    private func parseOffersResponse(_ data: Data) throws -> [Flight] {
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let dataArray = json?["data"] as? [[String: Any]] else {
            return []
        }
        
        var flights: [Flight] = []
        let dateFormatter = ISO8601DateFormatter()
        
        for offerDict in dataArray {
            guard let id = offerDict["id"] as? String,
                  let slices = offerDict["slices"] as? [[String: Any]],
                  let totalAmount = offerDict["total_amount"] as? String,
                  let totalCurrency = offerDict["total_currency"] as? String else {
                continue
            }
            
            // Parse first slice for outbound flight
            guard let firstSlice = slices.first,
                  let segments = firstSlice["segments"] as? [[String: Any]],
                  let firstSegment = segments.first,
                  let originDict = firstSegment["origin"] as? [String: Any],
                  let destinationDict = firstSegment["destination"] as? [String: Any],
                  let departingAt = firstSegment["departing_at"] as? String,
                  let arrivingAt = firstSegment["arriving_at"] as? String,
                  let duration = firstSlice["duration"] as? String else {
                continue
            }
            
            // Parse origin and destination
            let origin = parseAirport(from: originDict)
            let destination = parseAirport(from: destinationDict)
            
            // Parse dates
            guard let departureDate = dateFormatter.date(from: departingAt),
                  let arrivalDate = dateFormatter.date(from: arrivingAt) else {
                continue
            }
            
            // Parse airline and flight number
            let operatingCarrier = firstSegment["operating_carrier"] as? [String: Any]
            let airline = operatingCarrier?["name"] as? String ?? "Unknown"
            let flightNumber = (operatingCarrier?["iata_code"] as? String ?? "") + 
                             (firstSegment["operating_carrier_flight_number"] as? String ?? "")
            
            // Parse duration (format: "PT5H30M")
            let durationSeconds = parseDuration(duration)
            
            // Calculate stops
            let stops = segments.count - 1
            
            // Parse price
            let price = Double(totalAmount) ?? 0.0
            
            // Create flight legs for multi-leg journeys
            var legs: [FlightLeg]? = nil
            if segments.count > 1 {
                legs = segments.compactMap { segmentDict -> FlightLeg? in
                    guard let segmentId = segmentDict["id"] as? String,
                          let segOriginDict = segmentDict["origin"] as? [String: Any],
                          let segDestDict = segmentDict["destination"] as? [String: Any],
                          let segDepartingAt = segmentDict["departing_at"] as? String,
                          let segArrivingAt = segmentDict["arriving_at"] as? String,
                          let segDuration = segmentDict["duration"] as? String,
                          let segDepartDate = dateFormatter.date(from: segDepartingAt),
                          let segArriveDate = dateFormatter.date(from: segArrivingAt) else {
                        return nil
                    }
                    
                    let segOrigin = parseAirport(from: segOriginDict)
                    let segDest = parseAirport(from: segDestDict)
                    let segOperatingCarrier = segmentDict["operating_carrier"] as? [String: Any]
                    let segAirline = segOperatingCarrier?["name"] as? String ?? "Unknown"
                    let segFlightNumber = (segOperatingCarrier?["iata_code"] as? String ?? "") +
                                        (segmentDict["operating_carrier_flight_number"] as? String ?? "")
                    
                    return FlightLeg(
                        id: segmentId,
                        origin: segOrigin,
                        destination: segDest,
                        departureDate: segDepartDate,
                        arrivalDate: segArriveDate,
                        airline: segAirline,
                        flightNumber: segFlightNumber,
                        duration: parseDuration(segDuration)
                    )
                }
            }
            
            let flight = Flight(
                id: id,
                origin: origin,
                destination: destination,
                departureDate: departureDate,
                arrivalDate: arrivalDate,
                price: price,
                currency: totalCurrency,
                airline: airline,
                flightNumber: flightNumber,
                availableSeats: 9, // Duffel doesn't provide this, using default
                cabinClass: .economy,
                duration: durationSeconds,
                stops: stops,
                isMultiLeg: segments.count > 1,
                legs: legs
            )
            
            flights.append(flight)
        }
        
        return flights
    }
    
    /// Parse airport information from API response
    private func parseAirport(from dict: [String: Any]) -> Airport {
        let code = dict["iata_code"] as? String ?? ""
        let name = dict["name"] as? String ?? ""
        let city = (dict["city"] as? [String: Any])?["name"] as? String ?? ""
        
        return Airport(
            code: code,
            name: name,
            city: city,
            country: "",
            latitude: nil,
            longitude: nil
        )
    }
    
    /// Parse ISO 8601 duration string (e.g., "PT5H30M") to seconds
    private func parseDuration(_ duration: String) -> TimeInterval {
        var hours = 0
        var minutes = 0
        
        let scanner = Scanner(string: duration)
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: "PTM")
        
        if let hoursRange = duration.range(of: #"(\d+)H"#, options: .regularExpression) {
            let hoursString = duration[hoursRange].dropLast().dropFirst(duration[..<hoursRange.lowerBound].count)
            hours = Int(hoursString) ?? 0
        }
        
        if let minutesRange = duration.range(of: #"(\d+)M"#, options: .regularExpression) {
            let minutesString = duration[minutesRange].dropLast().dropFirst(duration[..<minutesRange.lowerBound].count)
            minutes = Int(minutesString) ?? 0
        }
        
        return TimeInterval(hours * 3600 + minutes * 60)
    }
    
    // MARK: - Test Mode Sample Data
    
    /// Generate sample flight data for testing
    private func generateSampleFlights(
        origin: String,
        destination: String,
        departureDate: Date,
        passengers: Int,
        cabinClass: Flight.CabinClass
    ) -> [Flight] {
        let airports = Airport.samples
        let originAirport = airports.first { $0.code == origin } ?? airports[0]
        let destAirport = airports.first { $0.code == destination } ?? airports[1]
        
        // Generate 5-8 sample flights with varying prices
        let flightCount = Int.random(in: 5...8)
        var flights: [Flight] = []
        
        let basePrice = Double.random(in: 200...500)
        let airlines = ["Delta Airlines", "United Airlines", "American Airlines", "Southwest Airlines", "JetBlue"]
        
        for i in 0..<flightCount {
            let priceVariation = Double.random(in: -50...150)
            let price = basePrice + priceVariation + Double(i * 20)
            
            let departureTime = departureDate.addingTimeInterval(TimeInterval(i * 3600 * 2)) // Stagger by 2 hours
            let duration = TimeInterval.random(in: 10800...25200) // 3-7 hours
            let arrivalTime = departureTime.addingTimeInterval(duration)
            
            let stops = i % 3 == 0 ? 0 : (i % 2 == 0 ? 1 : 2)
            let airline = airlines[i % airlines.count]
            
            let flight = Flight(
                id: "test_flight_\(UUID().uuidString)",
                origin: originAirport,
                destination: destAirport,
                departureDate: departureTime,
                arrivalDate: arrivalTime,
                price: price,
                currency: "USD",
                airline: airline,
                flightNumber: "\(airline.prefix(2).uppercased())\(Int.random(in: 100...999))",
                availableSeats: Int.random(in: 3...20),
                cabinClass: cabinClass,
                duration: duration,
                stops: stops,
                isMultiLeg: stops > 0,
                legs: stops > 0 ? generateSampleLegs(
                    from: originAirport,
                    to: destAirport,
                    departureTime: departureTime,
                    arrivalTime: arrivalTime,
                    stops: stops
                ) : nil
            )
            
            flights.append(flight)
        }
        
        return flights.sorted { $0.price < $1.price }
    }
    
    /// Generate sample flight legs for multi-leg journeys
    private func generateSampleLegs(
        from origin: Airport,
        to destination: Airport,
        departureTime: Date,
        arrivalTime: Date,
        stops: Int
    ) -> [FlightLeg] {
        guard stops > 0 else { return [] }
        
        let airports = Airport.samples
        var legs: [FlightLeg] = []
        let totalDuration = arrivalTime.timeIntervalSince(departureTime)
        let segmentDuration = totalDuration / Double(stops + 1)
        
        var currentOrigin = origin
        var currentTime = departureTime
        
        for i in 0...stops {
            let nextDestination: Airport
            if i == stops {
                nextDestination = destination
            } else {
                // Pick a random intermediate airport
                nextDestination = airports.filter { $0.code != currentOrigin.code && $0.code != destination.code }.randomElement() ?? airports[2]
            }
            
            let legArrival = currentTime.addingTimeInterval(segmentDuration)
            
            let leg = FlightLeg(
                id: "leg_\(i)_\(UUID().uuidString)",
                origin: currentOrigin,
                destination: nextDestination,
                departureDate: currentTime,
                arrivalDate: legArrival,
                airline: ["Delta", "United", "American"].randomElement()!,
                flightNumber: "\(["DL", "UA", "AA"].randomElement()!)\(Int.random(in: 100...999))",
                duration: segmentDuration
            )
            
            legs.append(leg)
            
            // Update for next leg
            currentOrigin = nextDestination
            currentTime = legArrival.addingTimeInterval(3600) // 1 hour layover
        }
        
        return legs
    }
}
