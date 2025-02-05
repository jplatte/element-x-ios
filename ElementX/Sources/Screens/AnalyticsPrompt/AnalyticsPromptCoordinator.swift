//
// Copyright 2021 New Vector Ltd
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import SwiftUI

struct AnalyticsPromptCoordinatorParameters {
    /// The user session to use if analytics are enabled.
    let userSession: UserSessionProtocol
}

final class AnalyticsPromptCoordinator: Coordinator, Presentable {
    // MARK: - Properties
    
    // MARK: Private
    
    private let parameters: AnalyticsPromptCoordinatorParameters
    private let analyticsPromptHostingController: UIViewController
    private var analyticsPromptViewModel: AnalyticsPromptViewModel
    
    // MARK: Public

    // Must be used only internally
    var childCoordinators: [Coordinator] = []
    var callback: (@MainActor () -> Void)?
    
    // MARK: - Setup
    
    init(parameters: AnalyticsPromptCoordinatorParameters) {
        self.parameters = parameters
        
        let viewModel = AnalyticsPromptViewModel(termsURL: BuildSettings.analyticsConfiguration.termsURL)
        
        let view = AnalyticsPrompt(context: viewModel.context)
        analyticsPromptViewModel = viewModel
        analyticsPromptHostingController = UIHostingController(rootView: view)
    }
    
    // MARK: - Public
    
    func start() {
        MXLog.debug("Did start.")
        
        analyticsPromptViewModel.callback = { [weak self] result in
            MXLog.debug("AnalyticsPromptViewModel did complete with result: \(result).")
            
            guard let self = self else { return }
            
            switch result {
            case .enable:
                Analytics.shared.optIn(with: self.parameters.userSession)
                self.callback?()
            case .disable:
                Analytics.shared.optOut()
                self.callback?()
            }
        }
    }
    
    func toPresentable() -> UIViewController { analyticsPromptHostingController }

    func stop() { }
}
