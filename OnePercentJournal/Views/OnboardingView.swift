import SwiftUI







struct MovingCircle: View {
    let size: CGFloat
    let offset: CGFloat
    let duration: Double
    @State private var move = false
    
    var body: some View {
        Circle()
            .fill(AppTheme.primaryBlue.opacity(0.15))
            .frame(width: size, height: size)
            .offset(y: move ? offset : -offset)
            .animation(
                Animation.easeInOut(duration: duration)
                    .repeatForever(autoreverses: true),
                value: move
            )
            .onAppear {
                move = true
            }
            .ignoresSafeArea()
    }
}

struct WaveView: View {
    @State private var phase = 0.0
    

    let amplitude: Double = 20
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let width = size.width
                let height = size.height
                let centerY = height / 2
                let timeNow = timeline.date.timeIntervalSinceReferenceDate
                
                context.translateBy(x: 0, y: centerY)
                
                let path = Path { p in
                    p.move(to: CGPoint(x: 0, y: 0))
                    
                    for x in stride(from: 0, to: width, by: 1) {
                        let relativeX = x / 50
                        let y = sin(relativeX + timeNow) * amplitude
                        p.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                
                context.stroke(path, with: .color(AppTheme.primaryBlue.opacity(0.3)), lineWidth: 3)
            }
        }
    }
}

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    @State private var typingText = ""
    @State private var currentExampleIndex = 0
    @State private var isDeleting = false
    @State private var isAnimating = false
    @State private var userName = ""
    @State private var showError = false
    @State private var pulse = false
    @State private var showSparkles = false
    @AppStorage("userName") private var storedUserName = ""
    
    let examples = [
        "practiced mindfulness \nfor 5 minutes.",
        "learned something \nnew about Swift.",
        "showed kindness to \na stranger."
    ]
    
    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    var body: some View {
        TabView(selection: $currentPage) {
            // Updated Welcome/Hook Page
            ZStack {
                // Adjusted background animations for better framing
                MovingCircle(size: 250, offset: 100, duration: 4)
                    .offset(x: -120, y: -50)
                    .ignoresSafeArea()
                MovingCircle(size: 200, offset: 80, duration: 5)
                    .offset(x: 150, y: 200)
                    .ignoresSafeArea()
                MovingCircle(size: 150, offset: 70, duration: 3)
                    .offset(x: 180, y: -180)
                    .ignoresSafeArea()
                
                VStack {
                    Text("Small Steps,\nBig Changes")
                        .font(.custom("HelveticaNeue-Bold", size: 40))
                        .foregroundColor(AppTheme.textPrimaryDark)
                        .multilineTextAlignment(.center)
                        .padding(.top, 140)
                        .padding(.bottom, 50)
                    
                    VStack(spacing: 40) {
                        Text("Your daily choices\nshape who you become.")
                            .font(.custom("HelveticaNeue", size: 30))
                            .foregroundColor(AppTheme.textPrimary)
                            .multilineTextAlignment(.center)
                        
                        Text("Improve by 1% each day, and you'll be 37x better in a year.")
                            .font(.custom("HelveticaNeue", size: 30))
                            .foregroundColor(AppTheme.textPrimary)
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 30)
            }

            .tag(0)
            
            
            // Updated Second Page
            VStack {
                Text("To become 1% better today, I...")
                    .font(.custom("HelveticaNeue-Bold", size: 40))
                    .foregroundColor(AppTheme.textPrimaryDark)
                    .multilineTextAlignment(.center)
                    .padding(.top, 140)
                    .padding(.bottom, 50)
                
                Text(typingText)
                    .font(.custom("HelveticaNeue", size: 30))
                    .foregroundColor(AppTheme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(height: 100, alignment: .top)
                    .padding()
                
                WaveView()
                    .frame(height: 80)
                WaveView()
                    .frame(height: 80)

                WaveView()
                    .frame(height: 80)
                
                Spacer()
            }
            .padding(.horizontal, 30)
            .tag(1)
            .onAppear {
                isAnimating = true
            }
            .onDisappear {
                isAnimating = false
                typingText = ""
                currentExampleIndex = 0
                isDeleting = false
            }
            
            // Updated Third Page
            ZStack {


                    
                VStack {
                    Text("Ready to Begin?")
                        .font(.custom("HelveticaNeue-Bold", size: 40))
                        .foregroundColor(AppTheme.textPrimaryDark)
                        .multilineTextAlignment(.center)
                        .padding(.top, 140)
                        .padding(.bottom, 50)
                    
                    
                    VStack(spacing: 40){
                        Text("Start your journey of daily reflection and personal growth")
                            .font(.custom("HelveticaNeue", size: 30))
                            .foregroundColor(AppTheme.textPrimary)
                            .multilineTextAlignment(.center)
                        
                        VStack(spacing: 5) {
                            TextField("Enter your name", text: $userName)
                                .font(.custom("HelveticaNeue", size: 24))
                                .foregroundColor(AppTheme.textPrimary)
                                .multilineTextAlignment(.center)
                                .textFieldStyle(.plain)
                                .padding(.vertical, 10)
                                .overlay(
                                    Rectangle()
                                        .frame(height: 1)
                                        .foregroundColor(showError ? Color.red : AppTheme.primaryBlue)
                                        .offset(y: 20)
                                )
                                .onChange(of: userName) {
                                    showError = false
                                }
                            
                            if showError {
                                Text("Please enter your name to continue")
                                    .font(.system(size: 16, design: .serif))
                                    .foregroundColor(.red)
                                    .transition(.opacity)
                            }
                        }
                    }
                    
                    Spacer()
                    Spacer()

                    
                    Button(action: {
                        print("Button tapped") // Debug print
                        let trimmedName = userName.trimmingCharacters(in: .whitespacesAndNewlines)
                        if trimmedName.isEmpty {
                            withAnimation {
                                showError = true
                            }
                        } else {
                            print("Name is valid: \(trimmedName)") // Debug print
                            storedUserName = trimmedName
                            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                            hasCompletedOnboarding = true
                            withAnimation(.easeInOut(duration: 1)) {
                                    showSparkles = true
                                }
                            print("Onboarding completed") // Debug print
                        }
                    }) {
                        Text("Get Started")
                                .font(.custom("HelveticaNeue", size: 24))
                                .foregroundColor(AppTheme.textPrimary)
                                .padding()
                                .background(AppTheme.primaryBlue.opacity(0.8))
                                .cornerRadius(12)
                                .scaleEffect(pulse ? 1.05 : 1.0)
                                .opacity(pulse ? 1.0 : 0.8)
                                .onAppear {
                                    withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                                        pulse.toggle()
                                    }
                                }
                    }
                    
                    
                    .padding(.bottom, 100)
                    if showSparkles {
                        Image(systemName: "sparkles")
                            .font(.system(size: 80))
                            .foregroundColor(AppTheme.primaryBlue)
                            .scaleEffect(showSparkles ? 1.5 : 0.5)
                            .opacity(showSparkles ? 1 : 0)
                            .transition(.scale)
                    }
                }
                .padding(.horizontal, 30)
            .tag(2)
            }
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .background(AppTheme.backgroundBlue)
        .onReceive(timer) { _ in
            guard isAnimating else { return }
            animateText()
        }
    }
    
    private func animateText() {
        let example = examples[currentExampleIndex]
        
        if !isDeleting {
            if typingText.count < example.count {
                typingText.append(example[example.index(example.startIndex, offsetBy: typingText.count)])
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    isDeleting = true
                }
            }
        } else {
            if !typingText.isEmpty {
                typingText.removeLast()
            } else {
                isDeleting = false
                currentExampleIndex = (currentExampleIndex + 1) % examples.count
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    // Small pause before starting the next example
                }
            }
        }
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
} 
