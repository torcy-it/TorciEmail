//
//  CertificateEmailModal.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 04/02/26.
//

import SwiftUI

struct CertificateEmailModal: View {
    @Binding var showCertificatesModal: Bool
    let email: EmailItem
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Certificate Info Card
                    certificateInfoCard
                        .padding(.horizontal, 18)
                        .padding(.top, 20)
                    
                    // Timeline Section
                    VStack(alignment: .leading, spacing: 16) {
                        // Timeline Header
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Timeline of Certified Events")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("\(email.events.count) legal affidavits generated")
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 18)
                        
                        // Timeline Events
                        if email.events.isEmpty {
                            emptyState
                        } else {
                            timelineEvents
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("", systemImage: "xmark") {
                        showCertificatesModal = false
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Certified Events")
                        .font(.system(size: 17, weight: .semibold))
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Export Certificate", systemImage: "square.and.arrow.up") {
                            print("📤 Export certificate")
                        }
                        
                        Button("Share", systemImage: "square.and.arrow.up") {
                            print("📤 Share")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .toolbarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Certificate Info Card
    
    private var certificateInfoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with icon
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Certification Profile")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Text(certificationProfile)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
            }
            
            Divider()
            
            // Certificate Details
            VStack(spacing: 12) {
                InfoRow(label: "Delivery Mode", value: deliveryMode)
                InfoRow(label: "Expires", value: expirationFormatted)
                InfoRow(label: "Evidence ID", value: email.id, isMonospace: true)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.blue.opacity(0.1))
        )
    }
    
    // MARK: - Timeline Events
    
    @ViewBuilder
    private var timelineEvents: some View {
        let events = email.events
        
        VStack(spacing: 0) {
            ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                ExpandableCertificateEventRow(
                    event: event,
                    isFirst: index == 0,
                    isLast: index == events.count - 1
                )
            }
        }
        .padding(.horizontal, 18)
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.badge.clock")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No Events Yet")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.gray)
            
            Text("Certified events will appear here as they occur")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    // MARK: - Computed Properties
    
    private var certificationProfile: String {
        if !email.certificationLevel.isEmpty {
            return email.certificationLevel.joined(separator: ", ")
        }
        return "Standard"
    }
    
    private var deliveryMode: String {
        email.sourceChannel ?? "Web"
    }
    
    private var expirationFormatted: String {
        guard let expiration = email.expirationDate else {
            return "N/A"
        }
        return expiration
    }
}

// MARK: - Info Row

struct InfoRow: View {
    let label: String
    let value: String
    var isMonospace: Bool = false
    
    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(isMonospace ? .system(size: 13, design: .monospaced) : .system(size: 14, weight: .medium))
                .foregroundColor(.primary)
                .multilineTextAlignment(.trailing)
        }
    }
}

// MARK: - Expandable Certificate Event Row

struct ExpandableCertificateEventRow: View {
    let event: EmailEvent
    let isFirst: Bool
    let isLast: Bool
    
    @State private var isExpanded = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Timeline Line
            timelineLine
            
            // Event Content
            VStack(alignment: .leading, spacing: 0) {
                // Main Event Button
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isExpanded.toggle()
                    }
                } label: {
                    eventHeader
                }
                .buttonStyle(.plain)
                
                // Expanded Details
                if isExpanded {
                    eventDetails
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
                
                Spacer()
                    .frame(height: isLast ? 0 : 24)
            }
        }
    }
    
    // MARK: - Timeline Line
    
    private var timelineLine: some View {
        VStack(spacing: 0) {
            if !isFirst {
                Rectangle()
                    .fill(eventColor.opacity(0.3))
                    .frame(width: 3, height: 24)
            }
            
            ZStack {
                Circle()
                    .fill(eventColor.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: eventIcon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(eventColor)
            }
            
            if !isLast {
                Rectangle()
                    .fill(eventColor.opacity(0.3))
                    .frame(width: 3)
                    .frame(maxHeight: .infinity)
            }
        }
        .frame(width: 44)
    }
    
    // MARK: - Event Header
    
    private var eventHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Timestamp
            Text(formattedTimestamp)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            
            // Event Title
            HStack {
                Text(eventTitle)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            
            // Certificate ID & Status
            HStack(spacing: 12) {
                Label(affidavitId, systemImage: "doc.text")
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(.secondary)
                
                Label("VERIFIED", systemImage: "checkmark.circle")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.green)
            }
            
            // Short Description
            Text(eventDescription)
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .lineLimit(isExpanded ? nil : 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
    
    // MARK: - Event Details
    
    private var eventDetails: some View {
        VStack(alignment: .leading, spacing: 16) {
            Divider()
                .padding(.horizontal, 16)
            
            VStack(alignment: .leading, spacing: 12) {
                DetailItem(label: "Event Type", value: eventTypeDetail)
                DetailItem(label: "Timestamp", value: fullTimestamp)
                DetailItem(label: "Status", value: "Verified")
                
                if let additionalInfo = additionalEventInfo {
                    DetailItem(label: "Details", value: additionalInfo)
                }
            }
            .padding(.horizontal, 16)
            
            // Action Buttons
            HStack(spacing: 12) {
                Button {
                    print("Show details for event: \(event.id)")
                } label: {
                    HStack {
                        Image(systemName: "doc.text.magnifyingglass")
                        Text("Show details")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.blue)
                }
                
                Spacer()
                
                Button {
                    print("Download affidavit for event: \(event.id)")
                } label: {
                    HStack {
                        Image(systemName: "arrow.down.doc")
                        Text("Download")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
    
    // MARK: - Computed Properties
    
    private var eventColor: Color {
        switch event.event {
        case .preparation: return .blue
        case .sending:
            if case .sending(.failed) = event.state {
                return .red
            }
            return .green
        case .delivery: return .orange
        case .reading: return .purple
        case .decision:
            if case .decision(.contentRejected) = event.state {
                return .red
            }
            if case .decision(.expired) = event.state {
                return .gray
            }
            return .green
        }
    }
    
    private var eventIcon: String {
        switch event.event {
        case .preparation: return "doc.text.fill"
        case .sending:
            if case .sending(.failed) = event.state {
                return "exclamationmark.triangle.fill"
            }
            return "paperplane.fill"
        case .delivery: return "shippingbox.fill"
        case .reading: return "envelope.open.fill"
        case .decision:
            if case .decision(.contentRejected) = event.state {
                return "xmark.circle.fill"
            }
            if case .decision(.expired) = event.state {
                return "clock.badge.xmark.fill"
            }
            return "checkmark.circle.fill"
        }
    }
    
    private var eventTitle: String {
        switch event.state {
        case .preparation(.pending): return "Message Submitted"
        case .preparation(.ready): return "Ready to Send"
        case .sending(.sent): return "Transmission Result"
        case .sending(.dispatched): return "Message Dispatched"
        case .sending(.delivered): return "Message Delivered"
        case .sending(.failed): return "Transmission Failed"
        case .delivery(.waiting): return "Awaiting Opening"
        case .reading(.opened): return "Message Opened"
        case .decision(.waitingDecision): return "Awaiting Response"
        case .decision(.contentAccepted): return "Content Accepted"
        case .decision(.contentRejected): return "Content Rejected"
        case .decision(.expired): return "Certificate Expired"
        }
    }
    
    private var eventDescription: String {
        switch event.state {
        case .preparation(.pending):
            return "Message submitted with additional graphical certificate attached"
        case .preparation(.ready):
            return "Message certified and ready for transmission"
        case .sending(.sent):
            return "Confirms whether message was successfully sent to recipient's mail server"
        case .sending(.dispatched):
            return "Message handed over to mail service provider"
        case .sending(.delivered):
            return "Message successfully delivered to recipient's mailbox"
        case .sending(.failed):
            return "An error occurred during the transmission process"
        case .delivery(.waiting):
            return "Message delivered, awaiting recipient to open it"
        case .reading(.opened):
            return "The recipient has opened and read the email"
        case .decision(.waitingDecision):
            return "Awaiting recipient's response to the message"
        case .decision(.contentAccepted):
            return "Recipient has accepted the message content"
        case .decision(.contentRejected):
            return "Recipient has rejected the message content"
        case .decision(.expired):
            return "Certificate validity period has expired"
        }
    }
    
    private var eventTypeDetail: String {
        switch event.state {
        case .preparation: return "Advanced Certification"
        case .sending: return "Transmission Status"
        case .delivery: return "Delivery Confirmation"
        case .reading: return "Read Receipt"
        case .decision: return "Response Status"
        }
    }
    
    private var affidavitId: String {
        let year = Calendar.current.component(.year, from: event.timestampUTC)
        let index = String(format: "%06d", abs(event.id.hashValue % 999999))
        return "AFF-\(year)-\(index)"
    }
    
    private var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy 'at' HH:mm"
        return formatter.string(from: event.timestampUTC)
    }
    
    private var fullTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .medium
        return formatter.string(from: event.timestampUTC)
    }
    
    private var additionalEventInfo: String? {
        switch event.state {
        case .sending(.sent):
            return "Message successfully transmitted through secure channels"
        case .reading(.opened):
            return "Recipient accessed the message content"
        case .decision(.contentAccepted):
            return "Formal acknowledgment of receipt and acceptance"
        default:
            return nil
        }
    }
}

// MARK: - Detail Item

struct DetailItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            
            Text(value)
                .font(.system(size: 15))
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Preview

#Preview {
    CertificateEmailModal(
        showCertificatesModal: .constant(true),
        email: .example
    )
}
