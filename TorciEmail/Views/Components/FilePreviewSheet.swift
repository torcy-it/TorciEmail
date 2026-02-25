//
//  FilePreviewSheet.swift
//  TorciEmail
//
//  Adattatore SwiftUI di QLPreviewController.
//  Consente anteprima locale di file scaricati in app.
//

import SwiftUI
import QuickLook

/// Foglio SwiftUI per anteprima di un singolo file URL.
struct FilePreviewSheet: UIViewControllerRepresentable {
    let url: URL
    
    /// Crea il coordinator datasource di QuickLook.
    func makeCoordinator() -> Coordinator {
        Coordinator(url: url)
    }
    
    /// Istanzia il controller QuickLook.
    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }
    
    /// Aggiorna l'URL in anteprima quando cambia lo stato.
    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {
        context.coordinator.url = url
        uiViewController.reloadData()
    }
    
    /// Coordinator datasource per QLPreviewController.
    final class Coordinator: NSObject, QLPreviewControllerDataSource {
        var url: URL
        
        init(url: URL) {
            self.url = url
        }
        
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            1
        }
        
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            url as NSURL
        }
    }
}

