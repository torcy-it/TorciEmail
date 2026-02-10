//
//  CertificateEmailModal.swift
//  TorciEmail
//
//  Fixed to match EviMailMapper event structure
//

import SwiftUI

struct CertificateEmailModal: View {
    @Binding var showCertificatesModal: Bool
    let email: EmailItem
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    
                    // Certificate Header
                    certificateHeader
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                        .padding(.bottom, 32)
                    
                    // Divider
                    Rectangle()
                        .fill(Color(.separator).opacity(0.5))
                        .frame(height: 1)
                        .padding(.horizontal, 20)
                    
                    // Timeline Section
                    VStack(alignment: .leading, spacing: 20) {
                        // Section Header
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Event Timeline")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text("\(email.events.count) certified events")
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                        
                        // Timeline Events
                        if email.events.isEmpty {
                            emptyState
                        } else {
                            timelineEvents
                        }
                    }
                }
                .padding(.bottom, 32)
            }
            .background(Color(.systemBackground))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showCertificatesModal = false
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Certificates")
                        .font(.system(size: 17, weight: .semibold))
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            print("Export certificate")
                        } label: {
                            Label("Export Certificate", systemImage: "square.and.arrow.up")
                        }
                        
                        Button {
                            print("Share")
                        } label: {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .toolbarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Certificate Header
    
    private var certificateHeader: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Icon and Title
            HStack(alignment: .top, spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.strongPrimary.opacity(0.3))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 26))
                        .foregroundColor(.sky)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Certified Email")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text(email.certificationLevel ?? "Standard Certification")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.primary)
                }
            }
            
            // Certificate Details Grid
            VStack(spacing: 16) {
                HStack {
                    CertificateDetailCell(
                        label: "Unique ID",
                        value: formatUniqueId(email.id)
                    )
                    
                    Spacer()
                    
                    CertificateDetailCell(
                        label: "Status",
                        value: email.status.title,
                        valueColor: statusColor(email.status)
                    )
                }
                
                HStack {
                    CertificateDetailCell(
                        label: "Expires",
                        value: email.expirationDate ?? "N/A"
                    )
                    
                    Spacer()
                    
                    CertificateDetailCell(
                        label: "Events",
                        value: "\(email.events.count)"
                    )
                }
            }
        }
    }
    
    // MARK: - Timeline Events
    
    @ViewBuilder
    private var timelineEvents: some View {
        let sortedEvents = email.events.sorted { $0.timestampUTC < $1.timestampUTC }
        
        VStack(spacing: 0) {
            ForEach(Array(sortedEvents.enumerated()), id: \.element.id) { index, event in
                ProfessionalEventRow(
                    event: event,
                    isFirst: index == 0,
                    isLast: index == sortedEvents.count - 1
                )
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.6))
            
            Text("No Events Recorded")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.secondary)
            
            Text("Certified events will appear here once they occur")
                .font(.system(size: 14))
                .foregroundColor(.secondary.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
    }
    
    // MARK: - Helper Methods
    
    private func formatUniqueId(_ id: String) -> String {
        if id.count > 12 {
            return String(id.prefix(8)) + "..." + String(id.suffix(4))
        }
        return id
    }
    
    private func statusColor(_ status: EmailStatus) -> Color {
        switch status {
        case .sent, .delivered, .read, .replied: return .green
        case .failed: return .red
        case .new, .ready: return .orange
        case .expired, .closed: return .gray
        default: return .blue
        }
    }
}

// MARK: - Certificate Detail Cell

struct CertificateDetailCell: View {
    let label: String
    let value: String
    var valueColor: Color = .primary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)
            
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(valueColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Professional Event Row

struct ProfessionalEventRow: View {
    let event: EmailEvent
    let isFirst: Bool
    let isLast: Bool
    
    @State private var isExpanded = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Timeline indicator
            timelineIndicator
            
            // Event content
            VStack(alignment: .leading, spacing: 0) {
                eventCard
                
                if !isLast {
                    Spacer()
                        .frame(height: 16)
                }
            }
        }
    }
    
    // MARK: - Timeline Indicator
    
    private var timelineIndicator: some View {
        VStack(spacing: 0) {
            // Top line
            if !isFirst {
                Rectangle()
                    .fill(eventColor.opacity(0.25))
                    .frame(width: 2, height: 20)
            }
            
            // Circle
            ZStack {
                Circle()
                    .fill(eventColor.opacity(0.15))
                    .frame(width: 32, height: 32)
                
                Circle()
                    .stroke(eventColor, lineWidth: 2)
                    .frame(width: 32, height: 32)
                
                Image(systemName: eventIcon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(eventColor)
            }
            
            // Bottom line
            if !isLast {
                Rectangle()
                    .fill(eventColor.opacity(0.25))
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
            }
        }
        .frame(width: 32)
    }
    
    // MARK: - Event Card
    
    private var eventCard: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                isExpanded.toggle()
            }
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                // Main content
                VStack(alignment: .leading, spacing: 12) {
                    // Timestamp
                    Text(formattedTimestamp)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    // Title and chevron
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(eventTitle)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            if !event.description.isEmpty {
                                Text(event.description)
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                    .lineLimit(isExpanded ? nil : 2)
                            } else {
                                Text(defaultDescription)
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                    .lineLimit(isExpanded ? nil : 2)
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.secondary)
                            .padding(.top, 2)
                    }
                }
                .padding(16)
                
                // Expanded details
                if isExpanded {
                    Divider()
                        .padding(.horizontal, 16)
                    
                    VStack(alignment: .leading, spacing: 14) {
                        // Event type
                        EventDetailRow(label: "Event Type", value: eventTypeDetail)
                        
                        // Full timestamp
                        EventDetailRow(label: "Timestamp", value: fullTimestamp)
                        
                        // Affidavit ID
                        EventDetailRow(label: "Affidavit ID", value: affidavitId, isMonospaced: true)
                        
                        // Status
                        HStack {
                            Text("Status")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 12))
                                Text("VERIFIED")
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .foregroundColor(.green)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.green.opacity(0.1))
                            )
                        }
                        
                        // Additional info
                        if let additionalInfo = additionalEventInfo {
                            EventDetailRow(label: "Details", value: additionalInfo)
                        }
                    }
                    .padding(16)
                    .padding(.top, 4)
                    
                    // Actions
                    Divider()
                        .padding(.horizontal, 16)
                    
                    HStack(spacing: 16) {
                        Button {
                            print("📄 View details for: \(event.id)")
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "doc.text.magnifyingglass")
                                    .font(.system(size: 14))
                                Text("View Details")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(.blue)
                        }
                        
                        Spacer()
                        
                        Button {
                            print("⬇️ Download affidavit: \(event.id)")
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.down.doc")
                                    .font(.system(size: 14))
                                Text("Download")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(.blue)
                        }
                    }
                    .padding(16)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.separator).opacity(0.5), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Computed Properties
    
    private var eventColor: Color {
        switch event.event {
        case .preparation:
            return .blue
        case .sending:
            if case .sending(.failed) = event.state {
                return .red
            }
            return .green
        case .reading:
            if case .reading(.waiting) = event.state {
                return .orange
            }
            return .purple
        case .decision:
            if case .decision(.contentRejected) = event.state {
                return .red
            }
            if case .decision(.contentWaiting) = event.state {
                return .orange
            }
            return .green
        case .closing:
            return .gray
        }
    }
    
    private var eventIcon: String {
        switch event.event {
        case .preparation:
            return "doc.text"
        case .sending:
            if case .sending(.failed) = event.state {
                return "xmark"
            }
            return "paperplane"
        case .reading:
            if case .reading(.waiting) = event.state {
                return "hourglass"
            }
            return "envelope.open"
        case .decision:
            if case .decision(.contentRejected) = event.state {
                return "xmark"
            }
            if case .decision(.contentWaiting) = event.state {
                return "clock"
            }
            return "checkmark"
        case .closing:
            return "lock"
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
        case .reading(.waiting): return "Awaiting Opening"
        case .reading(.opened): return "Message Opened"
        case .decision(.contentWaiting): return "Awaiting Response"
        case .decision(.contentAccepted): return "Content Accepted"
        case .decision(.contentRejected): return "Content Rejected"
        case .closing(.closed): return "Certificate Closed"
        }
    }
    
    private var defaultDescription: String {
        switch event.state {
        case .preparation(.pending):
            return "Message certified and submitted for processing"
        case .preparation(.ready):
            return "Message ready for transmission to recipient"
        case .sending(.sent):
            return "Transmission status confirmed by mail server"
        case .sending(.dispatched):
            return "Message dispatched through mail service provider"
        case .sending(.delivered):
            return "Successfully delivered to recipient's mailbox"
        case .sending(.failed):
            return "Transmission error occurred during delivery"
        case .reading(.waiting):
            return "Delivered, awaiting recipient to open message"
        case .reading(.opened):
            return "Recipient has opened and viewed the message"
        case .decision(.contentWaiting):
            return "Awaiting recipient's formal response"
        case .decision(.contentAccepted):
            return "Recipient has formally accepted the content"
        case .decision(.contentRejected):
            return "Recipient has formally rejected the content"
        case .closing(.closed):
            return "Certificate validity period has ended"
        }
    }
    
    private var eventTypeDetail: String {
        switch event.event {
        case .preparation: return "Certification"
        case .sending: return "Transmission"
        case .reading: return "Delivery/Reading"
        case .decision: return "Response"
        case .closing: return "Validity"
        }
    }
    
    private var affidavitId: String {
        let year = Calendar.current.component(.year, from: event.timestampUTC)
        let index = String(format: "%06d", abs(event.id.hashValue % 999999))
        return "AFF-\(year)-\(index)"
    }
    
    private var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy • HH:mm"
        return formatter.string(from: event.timestampUTC)
    }
    
    private var fullTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy 'at' HH:mm:ss"
        return formatter.string(from: event.timestampUTC)
    }
    
    private var additionalEventInfo: String? {
        switch event.state {
        case .sending(.sent):
            return "Message successfully transmitted through secure channels with full audit trail"
        case .reading(.opened):
            return "Recipient accessed and viewed the certified message content"
        case .decision(.contentAccepted):
            return "Formal acknowledgment of receipt and acceptance of terms"
        case .decision(.contentRejected):
            return "Recipient has formally declined or rejected the proposed content"
        default:
            return nil
        }
    }
}

// MARK: - Event Detail Row

struct EventDetailRow: View {
    let label: String
    let value: String
    var isMonospaced: Bool = false
    
    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(isMonospaced ?
                    .system(size: 13, design: .monospaced) :
                    .system(size: 14, weight: .medium))
                .foregroundColor(.primary)
                .multilineTextAlignment(.trailing)
        }
    }
}

// MARK: - Preview

#Preview {
    CertificateEmailModal(
        showCertificatesModal: .constant(true),
        email: .exampleAccepted
    )
}
