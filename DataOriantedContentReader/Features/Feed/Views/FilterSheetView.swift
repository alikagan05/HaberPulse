// FilterSheetView.swift
// DataOriantedContentReader
// Features → Feed → Views

import SwiftUI

struct FilterSheetView: View {
    @Binding var selectedSection: String
    @Binding var fromDate: Date?
    @Binding var toDate: Date?
    var onApply: () async -> Void

    @Environment(\.dismiss) private var dismiss

    // Local state for sheet editing
    @State private var localSection: String
    @State private var localFromDate: Date
    @State private var localToDate: Date
    @State private var useFromDate = false
    @State private var useToDate   = false

    init(
        selectedSection: Binding<String>,
        fromDate: Binding<Date?>,
        toDate: Binding<Date?>,
        onApply: @escaping () async -> Void
    ) {
        _selectedSection = selectedSection
        _fromDate        = fromDate
        _toDate          = toDate
        self.onApply     = onApply
        _localSection    = State(initialValue: selectedSection.wrappedValue)
        _localFromDate   = State(initialValue: fromDate.wrappedValue ?? Date.daysAgo(30))
        _localToDate     = State(initialValue: toDate.wrappedValue ?? Date())
        _useFromDate     = State(initialValue: fromDate.wrappedValue != nil)
        _useToDate       = State(initialValue: toDate.wrappedValue != nil)
    }

    var body: some View {
        NavigationStack {
            Form {
                // MARK: Section Filter
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Endpoints.sections, id: \.id) { section in
                                Button {
                                    localSection = section.id
                                } label: {
                                    Text(NSLocalizedString(section.label, comment: ""))
                                        .font(.subheadline.weight(localSection == section.id ? .semibold : .regular))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(
                                            localSection == section.id
                                                ? Color.brandPrimary
                                                : Color(.tertiarySystemGroupedBackground)
                                        )
                                        .foregroundStyle(localSection == section.id ? .white : .primary)
                                        .clipShape(Capsule())
                                        .animation(.easeInOut(duration: 0.2), value: localSection)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text(NSLocalizedString("filter_section", comment: ""))
                }

                // MARK: Date Filters
                Section {
                    Toggle(NSLocalizedString("filter_from_date", comment: ""), isOn: $useFromDate.animation())
                    if useFromDate {
                        DatePicker(
                            "",
                            selection: $localFromDate,
                            in: ...Date(),
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                    }

                    Toggle(NSLocalizedString("filter_to_date", comment: ""), isOn: $useToDate.animation())
                    if useToDate {
                        DatePicker(
                            "",
                            selection: $localToDate,
                            in: ...Date(),
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                    }
                } header: {
                    Text(NSLocalizedString("filter_date_range", comment: ""))
                }

                // MARK: Reset
                Section {
                    Button(role: .destructive) {
                        localSection  = ""
                        localFromDate = Date.daysAgo(30)
                        localToDate   = Date()
                        useFromDate   = false
                        useToDate     = false
                    } label: {
                        Label(NSLocalizedString("filter_reset", comment: ""), systemImage: "xmark.circle")
                    }
                }
            }
            .navigationTitle(NSLocalizedString("filter_title", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("cancel", comment: "")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("apply", comment: "")) {
                        selectedSection = localSection
                        fromDate        = useFromDate ? localFromDate : nil
                        toDate          = useToDate   ? localToDate   : nil
                        Task {
                            await onApply()
                            dismiss()
                        }
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
