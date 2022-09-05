import Foundation

// Protocolo(interface) que define las propiedades para que un vehiculo aparque.
protocol Parkable: Hashable {
    var plate: String { get }
    var type: VehicleType { get }
    var discountCard: String? { get }
    var hasDiscountCard: Bool { get }
    var checkInTime: Date { get }
    var parkedTime: Int { get }
}

extension Parkable {
    var hasDiscountCard: Bool { discountCard != nil }
}

extension Parkable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(plate)
    }
}


// enumeracion que lo que hace es definir un tipo comun para un grupo de valores relacionados
enum VehicleType {
    case car
    case miniBus
    case bus
    case motorcycle
    
    var rate: Int {
        switch self {
        case .car: return 20
        case .motorcycle: return 15
        case .miniBus: return 25
        case .bus: return 30
        }
    }
}

// estructuras
// esta estructura hace referencia al parking
struct Parking {
    var vehicles: Set<Vehicle> = []
    let maxVehicles = 20
    var parkingStatics : (earnings: Int, vehicles: Int) = (0, 0)
    //check in
    mutating func checkInVehicle(_ vehicle: Vehicle, onFinish:(Bool) -> Void) {
        
        guard !vehicles.contains(vehicle) && maxVehicles > self.vehicles.count else {
            
            return onFinish(false)
        }
        
        self.vehicles.insert(vehicle)
        
        return onFinish(true)
    }
    
    //check out
    mutating func checkOutVehicle(plate:String, onSuccess: (Int) -> Void, onError: () -> Void) {
        // verificacion si el vehiculo existe
        let vehicleFound = self.vehicles.first(where: {$0.plate == plate})
        // se desempaqueta debido a el metodo first nos devuelve un optional
        guard let vehicle = vehicleFound else {
            onError()
            return
        }
        
        self.vehicles.remove(vehicle)
        let hasDiscount = vehicle.discountCard != nil
        let checkOutFee = self.calculateFee(type: vehicle.type, parkedTime: vehicle.parkedTime, hasDiscountCard: hasDiscount)
        self.parkingStatics.earnings += checkOutFee
        self.parkingStatics.vehicles += 1
        onSuccess(checkOutFee)
        return
    }
    
    private func calculateFee(type: VehicleType, parkedTime: Int, hasDiscountCard:Bool) -> Int {
        let hoursInMinute = 120
        var total = 0
        
        if parkedTime >= 120 {
            total = type.rate
        }else {
            let minutesLeft = Float(parkedTime - hoursInMinute)
            let feeBlocks = ceil((minutesLeft/15))
            total = type.rate + Int(feeBlocks) * (type.rate/4)
        }
        return hasDiscountCard ? Int(floor(Float(total) * 0.85)) : total
    }
    func showStatics() {
        print("\(self.parkingStatics.vehicles) vehicles have checked out and have earnings of $\(self.parkingStatics.earnings)")
    }
    func listVehicles(){
        self.vehicles.forEach {
            vehicle in
            print("Vehicle plate is \(vehicle.plate)")
        }
    }
}


// esta estructura hace referencia al vehiculo
struct Vehicle: Parkable, Hashable {
    let plate: String
    let type: VehicleType
    let checkInTime: Date = Date()
    var discountCard: String?
    var parkedTime: Int {
        Calendar.current.dateComponents([.minute], from: checkInTime, to: Date()).minute ?? 0
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(plate)
    }
    static func ==(lhs: Vehicle, rhs: Vehicle) -> Bool {
        lhs.plate == rhs.plate
    }
}




var alkeParking = Parking()


let vehicles = [
    Vehicle(plate: "AA111AA", type:VehicleType.car, discountCard: "DISCOUNT_CARD_001"),
    Vehicle(plate: "B222BBB", type: VehicleType.motorcycle, discountCard: nil),
    Vehicle(plate: "DD444DD", type: VehicleType.bus, discountCard: "DISCOUNT_CARD_002"),
    Vehicle(plate: "CC333CC", type: VehicleType.miniBus, discountCard: nil),
    Vehicle(plate: "DD55DD", type: VehicleType.bus, discountCard: "DISCOUNT_CARD_002"),
    Vehicle(plate: "AA111BB", type: VehicleType.car, discountCard: "DISCOUNT_CARD_003"),
    Vehicle(plate: "B222CCC", type: VehicleType.motorcycle, discountCard: "DISCOUNT_CARD_004"),
    Vehicle(plate: "CC333DD", type: VehicleType.miniBus, discountCard: nil),
    Vehicle(plate: "DD444EE", type: VehicleType.bus, discountCard: "DISCOUNT_CARD_005"),
    Vehicle(plate: "AA111CC", type: VehicleType.car, discountCard: nil),
    Vehicle(plate: "B222DDD", type: VehicleType.motorcycle, discountCard: nil),
    Vehicle(plate: "CC333EE", type: VehicleType.miniBus, discountCard: nil),
    Vehicle(plate: "DD444GG", type: VehicleType.bus, discountCard: "DISCOUNT_CARD_006"),
    Vehicle(plate: "AA111DD", type: VehicleType.car, discountCard: "DISCOUNT_CARD_007"),
    Vehicle(plate: "B222EEE", type: VehicleType.motorcycle, discountCard: nil),
    Vehicle(plate: "CC333FF", type: VehicleType.miniBus, discountCard: nil),
    Vehicle(plate: "AA444HH", type: VehicleType.bus, discountCard: "DISCOUNT_CARD_008"),
    Vehicle(plate: "AA888PP", type: VehicleType.car, discountCard: "DISCOUNT_CARD_009"),
    Vehicle(plate: "B555QQQ", type: VehicleType.motorcycle, discountCard: nil),
]


// Insertar 19 vehiculos(los primeros)

print("****")
print("Ingreso \(vehicles.count) vehiculos:")
vehicles.forEach {
    vehicle in
    alkeParking.checkInVehicle(vehicle) {
        canInsert in
        if !canInsert {
            print("Sorry, the check-in failed")
        }else {
            print("Welcome to AlkeParking!")
        }
    }
}
print("****")


// Prueba de ingreso de vehiculo existente
print("****")
print("Patente repetida:")
let repeated = Vehicle(plate: "AA111CC", type: VehicleType.car, discountCard: nil)
alkeParking.checkInVehicle(repeated) {
    canInsert in
    if !canInsert {
        print("Sorry, the check-in failed")
    }else {
        print("Welcome to AlkeParking!")
    }
}
print("****")

// Ingreso el vehiculo numero 20
print("****")
print("Se ingresa el vehiculo numero 20:")
let vehicle20 = Vehicle(plate: "BB712PP", type: VehicleType.motorcycle, discountCard: nil)
alkeParking.checkInVehicle(vehicle20) {
    canInsert in
    if !canInsert {
        print("Sorry, the check-in failed")
    }else{
        print("Welcome to AlkeParking!")
    }
}
print("****")

// Prueba de ingreso de vehiculo 21

print("****")
print("Ingresar vehiculo con el parking completo:")
let vehicle21 = Vehicle(plate: "UU986YH", type: VehicleType.miniBus, discountCard: nil)
alkeParking.checkInVehicle(vehicle21) {
    canInsert in
    if !canInsert {
        print("Sorry, the check-in failed")
    } else {
        print("Welcome to AlkeParking!")
    }
}
print("****")

// Prueba de checkout de vehiculo existente
print("****")
print("Ingresar 2 vehiculos existentes:")
alkeParking.checkOutVehicle(plate: "DD55DD") {
    fee in
    print("Your fee is $\(fee). Come back soon")
}onError: {
    print("Sorry, the check-out failed")
}
alkeParking.showStatics()

// Prueba de checkout de un vehiculo existente 2
print("****")
alkeParking.checkOutVehicle(plate: "AA444HH") {
    fee in
    print("Your fee is $\(fee). Come back soon")
} onError: {
    print("Sorry, the check-out failed")
}
alkeParking.showStatics()
