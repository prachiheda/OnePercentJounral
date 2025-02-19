import SwiftUI

struct AppTheme {
    static let primaryBlue = Color(red: 176/255, green: 196/255, blue: 222/255) // Soft sage blue
    static let secondaryBlue = Color(red: 137/255, green: 157/255, blue: 192/255) // Slightly darker sage blue
    static let backgroundBlue = Color(red: 245/255, green: 247/255, blue: 250/255) // Very light blue-tinted background
    static let cardBackground = Color.white // Card background color
    static let textPrimary = Color(red: 71/255, green: 85/255, blue: 105/255) // Soft dark blue-gray
    static let textSecondary = Color(red: 148/255, green: 163/255, blue: 184/255) // Lighter text color

    // Font styles with Helvetica Neue
    static let titleFont = Font.custom("HelveticaNeue-Bold", size: 40)
    static let bodyFont = Font.custom("HelveticaNeue", size: 20)
    static let captionFont = Font.custom("HelveticaNeue-Italic", size: 16)
}

// Custom button style
struct ZenButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(AppTheme.primaryBlue.opacity(0.2))
            .foregroundColor(AppTheme.textPrimary)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// Custom text field style
struct ZenTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(AppTheme.backgroundBlue)
            .cornerRadius(10)
            .font(AppTheme.bodyFont)
    }
} 
