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
                    Divider()
                        .padding(.horizontal, 25)
                    
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
                            Label("Export All Affidavits", systemImage: "square.and.arrow.up")
                        }
                        
                        Button {
                            print("Share")
                        } label: {
                            Label("Download All Affidavits", systemImage: "arrow.down.doc")
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
        VStack(alignment: .leading, spacing: 14) {

            HStack(alignment: .top, spacing: 14) {

                ZStack {
                    Circle()
                        .fill(Color.strongPrimary.opacity(0.22))
                        .frame(width: 54, height: 54)

                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.tail)
                }.padding(.top, 6)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Certified Email")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)

                    Text(email.id)
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .textSelection(.enabled)

                    Text(email.certificationLevel ?? "Standard Certification")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                }

                Spacer()
            }

            
            Divider()

            // Details row (footer)
            HStack(spacing: 0) {

                // LAST EVENT
                VStack(spacing: 6) {
                    Text("LAST EVENT")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary.opacity(0.7))
                        .tracking(0.8)

                    Text(email.status.title.uppercased())
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                .frame(width: 110, alignment: .center)

                // DATE
                VStack(spacing: 6) {
                    Text("LAST EVENT DATE")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary.opacity(0.7))
                        .tracking(0.8)

                    Text(email.events.last?.timestampRelative ?? "—")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
                .frame(width: 140, alignment: .center)
                .padding(.trailing, 12)

                // EVENTS
                VStack(spacing: 6) {
                    Text("EVENTS")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary.opacity(0.7))
                        .tracking(0.8)

                    Text("\(email.events.count)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                .frame(width: 52, alignment: .center)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 2)
            .padding(.top, 4)



        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 14)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.strongPrimary.opacity(0.22))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.strongPrimary.opacity(0.22), lineWidth: 1)
        )
    }

    
    // MARK: - Timeline Events
    @ViewBuilder
    private var timelineEvents: some View {
        let sortedEvents = email.events.sorted { $0.timestampUTC < $1.timestampUTC }
        
        VStack(spacing: 0) {
            ForEach(Array(sortedEvents.enumerated()), id: \.element.id) { index, event in
                EventRow(
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

    
    
}


// MARK: - Event Row

struct EventRow: View {
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
                    .fill(event.color.opacity(0.25))
                    .frame(width: 2, height: 20)
            }
            
            Image(event.icon)
                .renderingMode(.template)
                .foregroundStyle(event.color)
            
            
            // Bottom line
            if !isLast {
                Rectangle()
                    .fill(event.color.opacity(0.25))
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
                    Text(event.timestampReadable)
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
                        HStack(alignment: .top) {
                            Text("Event Type")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text(eventTypeDetail)
                                .font(
                                    .system(size: 13, weight: .medium))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.trailing)
                        }
                
                        
                        // Affidavit ID
                        HStack(alignment: .top) {
                            Text("Affidavit ID")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text(event.id.uuidString)
                                .font(
                                    .system(size: 12, weight: .medium))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.trailing)
                        }
    

                        
                        // Additional info
                        if let additionalInfo = additionalEventInfo {
                            HStack(alignment: .top) {
                                Text("Details")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text(additionalInfo)
                                    .font(
                                        .system(size: 13, weight: .medium))
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                    }
                    .padding(16)
                    .padding(.top, 4)
                    
                    // Actions
                    Divider()
                        .padding(.horizontal, 16)
                    
                    HStack(spacing: 16) {
                        Button {
                            print("View details for: \(event.id)")
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 14))
                                Text("Export")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(.blue)
                        }
                        
                        Spacer()
                        
                        Button {
                            print("Download affidavit: \(event.id)")
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


// MARK: - Preview

#Preview {
    CertificateEmailModal(
        showCertificatesModal: .constant(true),
        email: .exampleDeliveredNotRead,
    )
}

