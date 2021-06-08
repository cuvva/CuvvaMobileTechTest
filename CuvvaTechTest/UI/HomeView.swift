import SwiftUI
import Combine
struct HomeView: View {
    
    @ObservedObject var model: AppViewModel
    
    @Environment(\.now) var now
  
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack {
                    
                    if self.model.isLoading {
                        
                        ProgressView()
                        
                    } else {
                        
                        DebugSection()
                        
                        ActivePoliciesSection()
                        
                        GarageSection()
                        
                    }
                   
                    Spacer()
                    
                }
            }
            .environmentObject(self.model)
            .background(Color.offWhite.edgesIgnoringSafeArea(.all))
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                if self.model.activePolicies.isEmpty {
                    self.model.reload {
                        self.now.time
                    }
                }
            }
            .alert(isPresented: self.$model.hasError) {
                if let error = self.model.lastError {
                    return Alert(
                        title: Text(error.localizedDescription),
                        message: Text("\(error as NSError)"),
                        primaryButton: .default(Text("Retry")) {
                            self.model.reload {
                                self.now.time
                            }
                        },
                        secondaryButton: .cancel()
                    )
                } else {
                    return Alert(
                        title: Text("Error"),
                        message: Text("Something went horribly wrong"),
                        primaryButton: .default(Text("Retry")) {
                            self.model.reload {
                                self.now.time
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
        }
    }
}

struct DebugSection: View {
    
    @EnvironmentObject var model: AppViewModel
    
    @State var currentTime: String = ""
    
    @State var showsDatePicker = false
    
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .long
        return dateFormatter
    }()
    
    @Environment(\.now) var now
    
    var body: some View {
        VStack {
            VStack(spacing: 16) {
                Text("Debug Device Time")
                    .font(.body.bold())
                
                HStack {
                    Image(systemName: "calendar.badge.clock")
                    
                    if showsDatePicker {
                        DebugDatePicker(date: .init(get: {
                            self.now.time
                        }, set: {
                            self.now.setTime(to: $0)
                            self.model.refreshData(for: $0)
                        }))
                        Spacer()
                        Button("Done") {
                            showsDatePicker.toggle()
                        }
                    } else {
                        Text(currentTime)
                            .font(.footnote)
                            .onTapGesture {
                                self.showsDatePicker.toggle()
                            }
                        Spacer()
                    }
                }
            }
            .padding()
            .background(
                Rectangle()
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)
            )
        }
        .onReceive(now.$time) { now in
            currentTime = dateFormatter.string(from: now)
        }
        .padding(.vertical)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SectionHeader: View {
    
    let title: String
    
    var body: some View {
        Text(title)
            .font(.subheadline.bold())
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}


struct ActivePoliciesSection: View {
    
    @EnvironmentObject var model: AppViewModel
    
    @State private(set) var activePolicies = [Policy]()
    
    var body: some View {
        Section(header: SectionHeader(title: "Active Policies")) {
            ForEach(activePolicies) { policy in
                ActivePolicyView(activePolicy: policy, showVehicle: true)
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
        .onReceive(model.$activePolicies) {
            self.activePolicies = $0
        }
    }
}

struct GarageSection: View {
    
    @EnvironmentObject var model: AppViewModel
    
    @State private(set) var historicalVehicles = [Vehicle]()
    
    var body: some View {
        Section(header: SectionHeader(title: "Garage")) {
            ForEach(historicalVehicles) { vehicle in
                VehicleView(vehicle: vehicle)
                    .foregroundColor(.black)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)
                    )
               
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
        .onReceive(model.$historicalVehicles) {
            self.historicalVehicles = $0
        }
    }
}


struct DebugDatePicker: View {
    
    @Binding var date: Date
    
    @Environment(\.now) var now
    
    var body: some View {
        DatePicker("", selection: $date, displayedComponents: [.date, .hourAndMinute])
            .labelsHidden()
    }
    
}

struct ActivePolicyView: View {
    
    @State var activePolicy: Policy
    @Environment(\.policyTermFormatter) var formatter
    
    @Environment(\.now) var now
    
    @State private var policyDurationString: String = ""
    @State private var policyRemainingString: String = ""
    @State private var policyRemainingPercent: Double = 0.0
    
    
    let showVehicle: Bool
    
    var body: some View {
            
            VStack {
                
                if showVehicle {
                    VehicleView(vehicle: activePolicy.vehicle)
                        .padding(.bottom, 30)
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.primaryColor)
                                .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)
                        )
                }
                
                
                
                VStack(alignment: .leading, spacing: 16) {
                    
                    Text(policyDurationString)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                    
                    HStack {
                        Text("Policy ends in:")
                            .font(.body)
                        Text(policyRemainingString)
                            .font(.callout)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    
                    ProgressView(value: policyRemainingPercent)
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)
                )
                .offset(x: 0, y: showVehicle ? -30 : 0)
                
            }
            .onReceive(now.$time) { currentDate in
                withAnimation {
                    policyDurationString = formatter.durationString(for: activePolicy.term.duration)
                    policyRemainingString = formatter.durationRemainingString(for: activePolicy.term, relativeTo: currentDate)
                    policyRemainingPercent = formatter.durationRemainingPercent(for: activePolicy.term, relativeTo: currentDate)
                }
                
            }
    }
    
}

struct VehicleView: View {
    
    @State var vehicle: Vehicle
    
    @SceneStorage("HomeView.selectedVehicle") private var selectedVehicle: String?
    
    var body: some View {
        NavigationLink(destination: DetailView(vehicle: vehicle, selectedVehicleID: $selectedVehicle),
                       tag: vehicle.id,
                       selection: $selectedVehicle) {
            HStack(spacing: 16) {
                
                Image(systemName: "car.fill")
                    .font(Font.system(.subheadline))
                
                VStack(alignment: .leading) {
                    
                    
                    Text(vehicle.displayVRM)
                        .font(.body.bold())
                    
                    Text(vehicle.makeModel)
                        .font(.body)
                    
                }
                
                Spacer()
               
                Image(systemName: "chevron.forward")
                    .font(Font.system(.headline))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        
    }
}

struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(
            model: .init(
                apiClient: .mockEmpty,
                policyModel: MockPolicyModel(),
                policyStorage: MockPolicyStorage()
            )
        )
    }
}

