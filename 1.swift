import SwiftUI
import CoreBluetooth

struct ContentView: View {
    @State private var pixelColors = Array(repeating: Color.gray, count: 64)
    @State private var selectedColor: Color = .red
    @State private var intensity: Double = 200
    @State private var isConnected = false
    @State private var statusMessage = "Estado: Desconectado"
    
    var body: some View {
        VStack {
            Text("NeVa's Lamp").font(.largeTitle).foregroundColor(.purple)
            Spacer()
            
            // Matriz de píxeles
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(40)), count: 8), spacing: 5) {
                ForEach(0..<64, id: \.self) { index in
                    Rectangle()
                        .fill(pixelColors[index])
                        .frame(width: 40, height: 40)
                        .border(Color.pink, width: pixelColors[index] == selectedColor ? 2 : 0)
                        .onTapGesture {
                            pixelColors[index] = selectedColor
                        }
                }
            }
            
            Spacer()
            
            // Selector de color e intensidad
            ColorPicker("Selecciona un color", selection: $selectedColor)
                .padding()
            
            HStack {
                Text("Intensidad:")
                Slider(value: $intensity, in: 0...255, step: 1)
                Text("\(Int(intensity))")
            }
            .padding()
            
            // Botones de control
            HStack {
                Button(action: connectToDevice) {
                    Text(isConnected ? "Conectado" : "Conectar")
                }
                .disabled(isConnected)
                .buttonStyle(.borderedProminent)
                
                Button("Enviar Diseño", action: sendDesign)
                    .disabled(!isConnected)
                    .buttonStyle(.bordered)
            }
            .padding()
            
            Text(statusMessage)
                .foregroundColor(isConnected ? .green : .red)
                .padding()
        }
        .padding()
    }
    
    func connectToDevice() {
        // Implementar lógica de conexión Bluetooth
        statusMessage = "Conectando..."
        // ...
    }
    
    func sendDesign() {
        // Crear JSON con los datos de la matriz
        let configurations = pixelColors.enumerated().compactMap { index, color -> [String: Any]? in
            guard color != .gray else { return nil }
            return [
                "Red": color.components.red * 255,
                "Green": color.components.green * 255,
                "Blue": color.components.blue * 255,
                "Leds": [index],
                "PE": "1",
                "Intensidad": intensity
            ]
        }
        
        let json: [String: Any] = ["configuraciones": configurations]
        // Enviar JSON por Bluetooth
        statusMessage = "Diseño enviado"
    }
}

// Extensión para extraer componentes RGB de un Color
extension Color {
    var components: (red: Double, green: Double, blue: Double, opacity: Double) {
        let uiColor = UIColor(self)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (Double(red), Double(green), Double(blue), Double(alpha))
    }
}
