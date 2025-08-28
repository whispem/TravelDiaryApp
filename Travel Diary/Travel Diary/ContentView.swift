//
//  ContentView.swift
//  Travel Diary
//
//  Created by Emilie on 28/08/2025.
//

import SwiftUI

struct TravelDiaryApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}

// MARK: - Model
struct Trip: Identifiable, Equatable {
    let id: UUID = .init()
    var title: String
    var color: Color
}

// MARK: - Palette
extension Color {
    static let turquoise  = Color(red: 64/255,  green: 224/255, blue: 208/255)
    static let lightBlue  = Color(red: 173/255, green: 216/255, blue: 230/255)
    static let tealGreen  = Color(red: 0/255,   green: 128/255, blue: 128/255)
    static let duckBlue   = Color(red: 0/255,   green: 105/255, blue: 148/255)
}

// MARK: - Root TabView
struct MainTabView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("Trips", systemImage: "airplane")
                }
        }
    }
}

// MARK: - Trips Screen
struct ContentView: View {
    @State private var trips: [Trip] = [
        Trip(title: "Paris",     color: .tealGreen),
        Trip(title: "New York",  color: .duckBlue),
        Trip(title: "Rome",     color: .turquoise)
    ]
    @State private var showingAdd = false
    @State private var showingProfile = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                LinearGradient(colors: [.turquoise, .duckBlue],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(trips) { trip in
                            TripCard(trip: trip)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }

                Button(action: { showingAdd = true }) {
                    Image(systemName: "plus")
                        .font(.title)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding()
            }
            .navigationTitle("Travel Diary")
            .toolbar {
                // Compatible macOS + iOS
                ToolbarItem {
                    Button(action: { showingProfile = true }) {
                        Image(systemName: "person.circle")
                            .font(.title2)
                            .foregroundColor(.turquoise) // profil coloré
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddTripView { newTrip in
                    trips.insert(newTrip, at: 0)
                }
            }
            .sheet(isPresented: $showingProfile) {
                ProfileView()
            }
        }
    }
}

// MARK: - Trip Card
struct TripCard: View {
    let trip: Trip

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 20)
                .fill(glossyGradient(from: trip.color))
                .frame(height: 150)
                .shadow(radius: 5)

            Text(trip.title)
                .font(.title.bold())
                .foregroundColor(.white)
                .padding()
        }
    }
}

func glossyGradient(from base: Color) -> LinearGradient {
    LinearGradient(colors: [base.opacity(0.95), base.opacity(0.7)],
                   startPoint: .topLeading,
                   endPoint: .bottomTrailing)
}

// MARK: - Add Trip View
struct AddTripView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title: String = ""
    @State private var selectedColor: Color = .turquoise

    var onAdd: (Trip) -> Void
    let colors: [Color] = [.turquoise, .lightBlue, .tealGreen, .duckBlue]

    var body: some View {
        VStack(spacing: 20) {
            TextField("Destination", text: $title)
                .textFieldStyle(.roundedBorder)
                .padding()

            HStack {
                ForEach(colors, id: \.self) { color in
                    Circle()
                        .fill(color)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Circle().stroke(Color.black.opacity(0.3),
                                            lineWidth: selectedColor == color ? 3 : 0)
                        )
                        .onTapGesture { selectedColor = color }
                }
            }

            Button("Save") {
                if !title.isEmpty {
                    onAdd(Trip(title: title, color: selectedColor))
                    dismiss()
                }
            }
            .buttonStyle(.borderedProminent)
            .padding()

            Spacer()
        }
        .padding()
        .frame(minWidth: 400, minHeight: 300)
    }
}

// MARK: - Profile View
struct ProfileView: View {
    @State private var isLoggedIn = false
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""

    var body: some View {
        VStack(spacing: 20) {
            if isLoggedIn {
                VStack(spacing: 12) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.black)

                    Text("Welcome, \(username.isEmpty ? "Traveler" : username)!")
                        .font(.title2)
                        .bold()

                    Button("Log Out") {
                        isLoggedIn = false
                        email = ""
                        password = ""
                        username = ""
                    }
                    .buttonStyle(.bordered)
                    .padding(.top)
                }
            } else {
                VStack(spacing: 16) {
                    Text("Create Account / Log In")
                        .font(.title2)
                        .bold()

                    TextField("Username", text: $username)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)

                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)

                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)

                    Button("Continue") {
                        if !email.isEmpty && !password.isEmpty {
                            isLoggedIn = true
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
            }
            Spacer()
        }
        .padding()
        .frame(minWidth: 400, minHeight: 300)
    }
}
