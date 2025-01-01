import SwiftUI

// MARK: - Category Picker
struct CategoryPicker: View {
    @Binding var selectedCategory: String
    let categories: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Kategori")
                .font(.custom("Outfit-Medium", size: 14))
                .foregroundColor(.secondary)
            
            Menu {
                ForEach(categories, id: \.self) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        HStack {
                            Text(category)
                            if selectedCategory == category {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Text(selectedCategory)
                        .font(.custom("Outfit-Regular", size: 16))
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(Color("NeutralBlack"))
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                )
            }
        }
    }
}

// MARK: - Add Attachment Button
struct AddAttachmentButton: View {
    @Binding var showDocumentPicker: Bool
    
    var body: some View {
        Button {
            showDocumentPicker = true
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Dosya Ekle")
                    .font(.custom("Outfit-Medium", size: 14))
            }
            .foregroundColor(Color("BittersweetOrange"))
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color("BittersweetOrange").opacity(0.3), lineWidth: 1)
                    .background(Color("BittersweetOrange").opacity(0.05))
            )
        }
    }
}

// MARK: - Tag Input
struct TagInput: View {
    @Binding var newTag: String
    @Binding var tags: [String]
    
    var body: some View {
        HStack {
            CustomTextField(
                placeholder: "Yeni etiket",
                text: $newTag

            )
            
            Button {
                addTag()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(Color("BittersweetOrange"))
                    .font(.system(size: 24))
            }
        }
    }
    
    private func addTag() {
        if !newTag.isEmpty && !tags.contains(newTag) {
            tags.append(newTag)
            newTag = ""
        }
    }
}

// MARK: - Tag List
struct TagList: View {
    @Binding var tags: [String]
    
    var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(tags, id: \.self) { tag in
                TagView(tag: tag) {
                    tags.removeAll { $0 == tag }
                }
            }
        }
    }
}

// MARK: - Preview Button
struct PreviewButton: View {
    @Binding var showPreview: Bool
    
    var body: some View {
        Button {
            showPreview = true
        } label: {
            HStack {
                Image(systemName: "eye")
                Text("Önizle")
            }
            .font(.custom("Outfit-Medium", size: 16))
            .foregroundColor(Color("BittersweetOrange"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("BittersweetOrange").opacity(0.1))
            )
        }
    }
}

// MARK: - Save Button
struct SaveButton: View {
    let isDisabled: Bool
    let onSave: () -> Void
    
    var body: some View {
        CustomButtonView(
            title: "Kaydet",
            disabled: isDisabled,
            type: .primary,
            action: onSave
        )
    }
}
