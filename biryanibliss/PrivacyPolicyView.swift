//
//  PrivacyPolicyView.swift
//  ChipTally
//
//  Created by Rahul Yarlagadda on 8/22/25.
//

import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Privacy Policy")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom)
                    
                    Text("Last updated: January 2025")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    PolicySection(
                        title: "Information We Collect",
                        content: "ChipTally stores your game session data and player group information locally on your device. We do not collect, transmit, or store any personal information on external servers."
                    )
                    
                    PolicySection(
                        title: "How We Use Your Information",
                        content: "Your data is used solely to provide the poker session management functionality within the app. All data remains on your device and is not shared with third parties."
                    )
                    
                    PolicySection(
                        title: "Data Storage",
                        content: "All game sessions, player groups, and settings are stored locally on your device using iOS's secure storage mechanisms. This data is not backed up to iCloud or any external service."
                    )
                    
                    PolicySection(
                        title: "Data Security",
                        content: "Your data is protected by iOS's built-in security features. We implement industry-standard practices to ensure your information remains secure on your device."
                    )
                    
                    PolicySection(
                        title: "Third-Party Services",
                        content: "ChipTally does not integrate with any third-party analytics, advertising, or data collection services. Your privacy is our priority."
                    )
                    
                    PolicySection(
                        title: "Children's Privacy",
                        content: "ChipTally is designed for users 13 years and older. We do not knowingly collect information from children under 13."
                    )
                    
                    PolicySection(
                        title: "Changes to This Policy",
                        content: "We may update this privacy policy from time to time. Any changes will be reflected in the app and indicated by the 'Last updated' date above."
                    )
                    
                    PolicySection(
                        title: "Contact Us",
                        content: "If you have any questions about this privacy policy or ChipTally's privacy practices, please contact us through the App Store."
                    )
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PolicySection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(content)
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding(.bottom, 8)
    }
}

struct PrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyPolicyView()
    }
}
