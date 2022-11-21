//
//  Toast.swift
//  AutoDB
//
//Rember there is another COLOR in decode.swift
//Taken From: https://betterprogramming.pub/swiftui-create-a-fancy-toast-component-in-10-minutes-e6bae6021984

import SwiftUI

extension Color {
    struct MyTheme {
      static var firstColor: UIColor  { return UIColor(red: 1, green: 0, blue: 0, alpha: 1) }
      static var secondColor: UIColor { return UIColor(red: 0, green: 1, blue: 0, alpha: 1) }
    }
}

struct Toast: Equatable {
    var type: ToastStyle
    var headline: String
    var subtitle: String
    var duration: Double = 5
}

enum ToastStyle {
    case error
    case warning
    case success

    
    var color: Color {
        switch self {
        case .error: return .red
        case .success: return .green
        case .warning: return .yellow
        }
    }
    
    var icon: String {
        switch self {
            case .warning: return "exclamationmark.triangle.fill"
            case .success: return "checkmark.circle.fill"
            case .error: return "xmark.circle.fill"
        }
    }
}



struct ToastView: View {
    var type: ToastStyle
    var title: String
    var message: String
    var onCancelTapped: (() -> Void)
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Image(systemName: type.icon)
                    .foregroundColor(type.color)
                
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                    
                    Text(message)
                        .font(.system(size: 12))
                        .foregroundColor(.black.opacity(0.6))
                }
                
                Spacer(minLength: 10)
                
            }
            .padding()
        }
        .background(.white)
        .overlay(
            Rectangle()
                .fill(type.color)
                .frame(width: 6)
                .clipped()
            , alignment: .leading
        )
        .frame(minWidth: 0, maxWidth: .infinity)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 1)
        .padding(.horizontal, 16)
    }
}

extension ToastView {
    
    func returnColor(type: String) -> Color {
        switch type {
        case "r": return .red
        case "g": return .green
        case "b": return .blue
        default:
            return .gray
        }
    }
}


struct ToastModifier: ViewModifier {
    @Binding var toast: Toast?
    @State private var workItem: DispatchWorkItem?
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(
                ZStack {
                    mainToastView()
                        .offset(y: -30)
                }.animation(.spring(), value: toast)
            )
            .onChange(of: toast) { value in
                showToast()
            }
    }
    
    @ViewBuilder func mainToastView() -> some View {
        if let toast = toast {
            VStack {
                Spacer()
                ToastView(
                    type: toast.type,
                    title: toast.headline,
                    message: toast.subtitle) {
                        dismissToast()
                    }
            }
            .transition(.move(edge: .bottom))
        }
    }
    
    private func showToast() {
        guard let toast = toast else { return }
        
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        if toast.duration > 0 {
            workItem?.cancel()
            
            let task = DispatchWorkItem {
               dismissToast()
            }
            
            workItem = task
            DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration, execute: task)
        }
    }
    
    private func dismissToast() {
        withAnimation {
            toast = nil
        }
        
        workItem?.cancel()
        workItem = nil
    }
}


extension View {
    func toastView(toast: Binding<Toast?>) -> some View {
        self.modifier(ToastModifier(toast: toast))
    }
}

