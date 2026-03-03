//
//  CertificationTabView.swift
//  CertfiedEmail
//
//  Tab certificazione composizione.
//  Configura livello, lingua affidavit, step certificati e regole motivazioni.
//

import SwiftUI

// MARK: - Affidavit Step Model
/// Step configurabile del workflow affidavit.
struct AffidavitStep: Identifiable {
    let id = UUID()
    let title: String
    let apiValue: String
    var isAdvanced: Bool = false
    var isEnabled: Bool = true
}

/// Campo attualmente in focus nei reason input.
enum FocusedReason {
    case accept, reject
}

// MARK: - Certification Tab View
/// Vista di configurazione certificazione e reason policy.
struct CertificationTabView: View {
    @ObservedObject var viewModel: ComposeMailViewModel
    @State private var newAcceptReason: String = ""
    @State private var newRejectReason: String = ""
    @FocusState private var focusedField: FocusedReason?
    @State private var acceptionReasons: [String] = []
    @State private var newAcceptionReason: String = ""
    @FocusState private var isAcceptionReasonFocused: Bool
    @State private var rejectionReasons: [String] = []
    @State private var newRejectionReason: String = ""
    @FocusState private var isRejectionReasonFocused: Bool

    /// Renderizza tutte le sezioni di configurazione certificazione.
    var body: some View {
        VStack(spacing: 0) {

            VStack(spacing: 0) {
                // MARK: - Certification Level
                Menu {
                    ForEach(["Advanced (EU)", "Standard (EU)"], id: \.self) { option in
                        Button {
                            viewModel.certificationLevel = option
                        } label: {
                            if viewModel.certificationLevel == option {
                                Label(option, systemImage: "checkmark")
                            } else {
                                Text(option)
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text("Certification Level:")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.primary)
                        Spacer()
                        Text(viewModel.certificationLevel)
                            .font(.system(size: 17))
                            .foregroundColor(Color(red: 0.35, green: 0.66, blue: 0.54))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 0.35, green: 0.66, blue: 0.54))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)
                    .padding(.top, 16)
                }

                // MARK: - Affidavit Language
                Menu {
                    ForEach(viewModel.availableLanguages, id: \.self) { lang in
                        Button {
                            viewModel.affidavitLanguage = lang
                        } label: {
                            if viewModel.affidavitLanguage == lang {
                                Label(lang == "en" ? "English" : "Italian", systemImage: "checkmark")
                            } else {
                                Text(lang == "en" ? "English" : "Italian")
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text("Affidavit Language:")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.primary)
                        Spacer()
                        Text(viewModel.affidavitLanguage == "en" ? "English" : "Italian")
                            .font(.system(size: 17))
                            .foregroundColor(Color(red: 0.35, green: 0.66, blue: 0.54))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 0.35, green: 0.66, blue: 0.54))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)
                }

                // MARK: - Appearance
                Menu {
                    ForEach(["Certified", "As Is"], id: \.self) { option in
                        Button {
                            viewModel.appearance = option
                        } label: {
                            if viewModel.appearance == option {
                                Label(option, systemImage: "checkmark")
                            } else {
                                Text(option)
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text("Appearance:")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.primary)
                        Spacer()
                        Text(viewModel.appearance)
                            .font(.system(size: 17))
                            .foregroundColor(Color(red: 0.35, green: 0.66, blue: 0.54))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 0.35, green: 0.66, blue: 0.54))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)
                }

                // MARK: - Tracking Until
                HStack {
                    Text("Tracking Until:")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.primary)
                    Spacer()
                    DatePicker(
                        "",
                        selection: $viewModel.trackingUntil,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    .tint(Color(red: 0.35, green: 0.66, blue: 0.54))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
                .padding(.bottom, 10)
            }
            .background(Color(red: 0.88, green: 0.95, blue: 0.92))
            .cornerRadius(16)
            .padding(.horizontal)
            .padding(.bottom, 20)

            // MARK: - Affidavit Grid
            VStack(alignment: .leading, spacing: 12) {
                Text("Affidavit")
                    .font(.system(size: 17, weight: .semibold))
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                AffidavitGridView(steps: $viewModel.affidavitSteps)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
            }
            .background(Color(red: 0.88, green: 0.95, blue: 0.92))
            .cornerRadius(16)
            .padding(.horizontal)
            .padding(.bottom, 20)

            VStack {
                HStack {
                    Text("Allow recipient to add a reason")
                        .font(.system(size: 16, weight: .medium))
                    Spacer()
                    Toggle("", isOn: $viewModel.allowReasons)
                        .labelsHidden()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)

                // MARK: - Agreement Possibilities
                if viewModel.allowReasons {
                    Menu {
                        ForEach(["Accept", "Accept / Reject", "Reject"], id: \.self) { opt in
                            Button {
                                viewModel.agreementPossibilities = opt
                            } label: {
                                if viewModel.agreementPossibilities == opt {
                                    Label(opt, systemImage: "checkmark")
                                } else {
                                    Text(opt)
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text("Agreement Possibilities:")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(viewModel.agreementPossibilities)
                                .font(.system(size: 17))
                                .foregroundColor(Color(red: 0.35, green: 0.66, blue: 0.54))
                            Image(systemName: "chevron.down")
                                .font(.system(size: 14))
                                .foregroundColor(Color(red: 0.35, green: 0.66, blue: 0.54))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)

                    if viewModel.agreementPossibilities != "Reject" {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Acceptance reasons")
                                .font(.system(size: 16, weight: .semibold))
                                .padding(.horizontal, 4)

                            ReasonTagInputView(
                                reasons: $viewModel.acceptReasons,
                                newReason: $newAcceptReason,
                                placeholder: "Add acceptance reason..."
                            )

                            HStack(spacing: 12) {
                                Text("Require accept reason")
                                    .font(.system(size: 16, weight: .medium))
                                Spacer()
                                Toggle("", isOn: $viewModel.acceptReasonsRequired)
                                    .labelsHidden()
                            }
                            .padding(.horizontal, 4)
                            .padding(.top, 2)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                    }

                    if viewModel.agreementPossibilities != "Accept" {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Rejection reasons")
                                .font(.system(size: 17, weight: .semibold))
                                .padding(.horizontal, 4)

                            ReasonTagInputView(
                                reasons: $viewModel.rejectReasons,
                                newReason: $newRejectReason,
                                placeholder: "Add rejection reason..."
                            )

                            HStack {
                                Text("Require a reason to reject")
                                    .font(.system(size: 16, weight: .medium))
                                Spacer()
                                Toggle("", isOn: $viewModel.rejectReasonsRequired)
                                    .labelsHidden()
                            }
                            .padding(.horizontal, 4)
                            .padding(.top, 2)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 5)
                    }
                }
            }
            .background(Color(red: 0.88, green: 0.95, blue: 0.92))
            .cornerRadius(16)
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }

    // MARK: - Generic Menu Row
    @ViewBuilder
    /// Riga menu riusabile per selezione opzione testuale.
    private func menuRow(label: String, options: [String], selected: Binding<String>) -> some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button {
                    selected.wrappedValue = option
                } label: {
                    if selected.wrappedValue == option {
                        Label(option, systemImage: "checkmark")
                    } else {
                        Text(option)
                    }
                }
            }
        } label: {
            HStack {
                Text(label)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.primary)
                Spacer()
                Text(selected.wrappedValue)
                    .font(.system(size: 17))
                    .foregroundColor(Color(red: 0.35, green: 0.66, blue: 0.54))
                Image(systemName: "chevron.down")
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 0.35, green: 0.66, blue: 0.54))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color(red: 0.88, green: 0.95, blue: 0.92))
        .cornerRadius(16)
        .padding(.horizontal)
        .padding(.bottom, 20)
    }
}

// MARK: - Reason Tag Input View
/// Input tag orizzontale per motivazioni di accettazione/rifiuto.
struct ReasonTagInputView: View {
    @Binding var reasons: [String]
    @Binding var newReason: String
    var placeholder: String = "Add a reason..."
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(reasons, id: \.self) { reason in
                        HStack(spacing: 4) {
                            Text(reason)
                                .font(.system(size: 13))
                                .foregroundColor(Color(red: 0.25, green: 0.60, blue: 0.50))
                            Button {
                                reasons.removeAll { $0 == reason }
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(Color(red: 0.25, green: 0.60, blue: 0.50))
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(Color(red: 0.75, green: 0.93, blue: 0.88)))
                    }

                    TextField(reasons.isEmpty ? placeholder : "", text: $newReason)
                        .font(.system(size: 15))
                        .foregroundColor(.primary)
                        .focused($isFocused)
                        .onSubmit {
                            let trimmed = newReason.trimmingCharacters(in: .whitespaces)
                            if !trimmed.isEmpty && !reasons.contains(trimmed) {
                                reasons.append(trimmed)
                                newReason = ""
                            }
                            isFocused = true
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 15)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
}

// MARK: - Affidavit Grid
/// Griglia step affidavit con binding bidirezionale.
struct AffidavitGridView: View {
    @Binding var steps: [AffidavitStep]
    let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach($steps) { $step in
                AffidavitStepCell(step: $step)
            }
        }
    }
}

// MARK: - Affidavit Step Cell
/// Cella singolo step affidavit con stato enable/disable.
struct AffidavitStepCell: View {
    @Binding var step: AffidavitStep

    private let enabledBg   = Color(red: 0.68, green: 0.90, blue: 0.84)
    private let disabledBg  = Color(.systemGray5)
    private let enabledIcon = Color(red: 0.15, green: 0.15, blue: 0.15)
    private let disabledIcon = Color(.systemGray3)

    var body: some View {
        Button {
            step.isEnabled.toggle()
        } label: {
            VStack(spacing: 0) {
                Image(systemName: "checkmark.seal\(step.isEnabled ? ".fill" : "")")
                    .font(.system(size: 32, weight: step.isEnabled ? .bold : .regular))
                    .foregroundColor(step.isEnabled ? enabledIcon : disabledIcon)
                    .frame(height: 44)

                Text(step.title)
                    .font(.system(size: 9, weight: step.isEnabled ? .bold : .regular))
                    .foregroundColor(step.isEnabled ? .primary : .secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .frame(height: 36)

                Text("Advanced")
                    .font(.system(size: 9, weight: step.isEnabled ? .bold : .regular))
                    .foregroundColor(step.isEnabled ? .black : .gray)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .opacity(step.isAdvanced ? 1.0 : 0.0)
                    .frame(height: 18)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 6)
            .frame(maxWidth: 120)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(step.isEnabled ? enabledBg : disabledBg)
            )
        }
        .buttonStyle(.plain)
    }
}
