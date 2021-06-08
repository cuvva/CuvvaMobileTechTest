import SwiftUI
import Combine

@main
struct CuvvaTechTestApp: App {
    
    private static let useLive: Bool = true
    
    private var appModel: AppViewModel = {
        
        guard useLive else {
            return .init(
                apiClient: .mockEmpty,
                policyModel: MockPolicyModel(),
                policyStorage: MockPolicyStorage()
            )
        }
        let policyStorage = PolicyStorage()
        
        return .init(
            apiClient: .live,
            policyModel: LivePolicyEventProcessor(
                policyStorage: policyStorage
            ),
            policyStorage: policyStorage
        )
    }()
    
    var body: some Scene {
        WindowGroup {
            HomeView(model: appModel)
                .environment(\.policyTermFormatter, LivePolicyTermFormatter())
            /**
                The app uses a static time by default
                TODO: Uncomment the line below to use the device time
            */
               .environment(\.now, LiveTime())
        }
    }
}

// MARK: App View Model

class AppViewModel: ObservableObject {
    
    @Published private(set) var activePolicies = [Policy]()
    @Published private(set) var historicalVehicles = [Vehicle]()
    
    @Published var hasError = false
    @Published var isLoading = false
    
    private(set) var lastError: Error? {
        didSet {
            self.hasError = lastError != nil
        }
    }
    
    var cancellationToken: AnyCancellable?
    
    // MARK: Dependencies
    private let apiClient: APIClient
    private let policyModel: PolicyEventProcessor
    private let policyStorage: PolicyStorageProtocol
    
    // MARK: Public functions
    
    init(apiClient: APIClient,
         policyModel: PolicyEventProcessor,
         policyStorage: PolicyStorageProtocol) {
        self.apiClient = apiClient
        self.policyModel = policyModel
        self.policyStorage = policyStorage
    }
    
    func reload(date: @escaping () -> Date) {
        isLoading = true
        
        cancellationToken = apiClient.events()
            .print("APIClient Reload")
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        self.lastError = error
                        fallthrough
                    case .finished:
                        self.isLoading = false
                    }
                },
            receiveValue: { response in
                // Chebotov. Now we can add a test to check the new response is stored as well
                self.policyStorage.store(json: response)
                self.refreshData(for: date())
            }
        )
    }
    
    func refreshData(for date: Date) {
        let data = self.policyModel.retrieve(for: date)
        self.activePolicies = data.activePolicies
        self.historicalVehicles = data.historicVehicles
        self.objectWillChange.send()
    }
}
