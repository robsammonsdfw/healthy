import PDFKit
import UIKit
import WebKit

/// This class is responsible for generating a PDF report from the scan result.
class BodyScanResultsPDF: NSObject, WKNavigationDelegate {

    // MARK: - Types

    enum PDFError: Error {
        case templateNotFound
        case pdfGenerationFailed
        case noPDFsGenerated
    }

    // MARK: - Properties

    private let scanResult: ScanResult
    private let assetUrls: [String: String]?
    private let parentViewController: UIViewController
    private var pdfWebView: WKWebView?

    // MARK: - Initialization

    init(
        scanResult: ScanResult, assetUrls: [String: String]?, parentViewController: UIViewController
    ) {
        self.scanResult = scanResult
        self.assetUrls = assetUrls
        self.parentViewController = parentViewController
        super.init()
    }

    // MARK: - Public Methods

    func generatePDF(completion: @escaping (Result<URL, Error>) -> Void) {
        // Create and setup WebView
        let pdfWebView = WKWebView(frame: CGRect(x: 0, y: 0, width: 612, height: 792))
        pdfWebView.navigationDelegate = self
        pdfWebView.isHidden = true
        parentViewController.view.addSubview(pdfWebView)
        self.pdfWebView = pdfWebView

        // Start processing pages
        processNextPage(index: 0, pdfs: [], completion: completion)
    }

    // MARK: - Private Methods

    private func processNextPage(
        index: Int, pdfs: [Data], completion: @escaping (Result<URL, Error>) -> Void
    ) {
        let pageFiles = ["page1", "page2", "page3"]

        guard index < pageFiles.count else {
            // All pages done, combine PDFs
            debugPrint("🔄 Combining \(pdfs.count) PDFs")
            do {
                let combinedPDF = try combinePDFs(pdfs)
                debugPrint("✅ Combined PDF size: \(combinedPDF.count)")
                let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(
                    "health_report.pdf")
                try combinedPDF.write(to: outputURL)

                // Clean up
                self.pdfWebView?.removeFromSuperview()
                self.pdfWebView = nil

                completion(.success(outputURL))
            } catch {
                debugPrint("❌ Failed to combine PDFs: \(error)")
                completion(.failure(error))
            }
            return
        }

        let pageFile = pageFiles[index]
        guard let templateURL = Bundle.main.url(forResource: pageFile, withExtension: "html") else {
            debugPrint("❌ Could not find template for: \(pageFile)")
            processNextPage(index: index + 1, pdfs: pdfs, completion: completion)
            return
        }

        debugPrint("📄 Loading template: \(pageFile)")
        let reportDirectoryURL = templateURL.deletingLastPathComponent()

        do {
            let templateHTML = try String(contentsOf: templateURL, encoding: .utf8)
            debugPrint("📝 Template content length: \(templateHTML.count)")

            // Clear existing content
            pdfWebView?.loadHTMLString("", baseURL: nil)

            // Load new content
            pdfWebView?.loadFileURL(templateURL, allowingReadAccessTo: reportDirectoryURL)

            // Wait for navigation to complete before creating PDF
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                debugPrint("🔄 Creating PDF for page: \(pageFile)")

                guard let pdfWebView = self.pdfWebView else { return }

                // Verify content before PDF creation
                pdfWebView.evaluateJavaScript("document.body.innerHTML") { result, error in
                    debugPrint("📄 Page \(index + 1) content: \(String(describing: result))")
                    if let error = error {
                        debugPrint("❌ JavaScript error: \(error)")
                    }
                }

                let config = WKPDFConfiguration()
                config.rect = CGRect(x: 0, y: 0, width: 612, height: 792)

                pdfWebView.createPDF(configuration: config) { result in
                    switch result {
                    case .success(let pdfData):
                        debugPrint("✅ Created PDF for \(pageFile), size: \(pdfData.count)")
                        var updatedPdfs = pdfs
                        updatedPdfs.append(pdfData)
                        self.processNextPage(
                            index: index + 1, pdfs: updatedPdfs, completion: completion)
                    case .failure(let error):
                        debugPrint("❌ Failed to create PDF for \(pageFile): \(error)")
                        self.processNextPage(index: index + 1, pdfs: pdfs, completion: completion)
                    }
                }
            }
        } catch {
            debugPrint("❌ Error loading template: \(error)")
            processNextPage(index: index + 1, pdfs: pdfs, completion: completion)
        }
    }

    private func combinePDFs(_ pdfs: [Data]) throws -> Data {
        guard !pdfs.isEmpty else { throw PDFError.noPDFsGenerated }

        let pdfDocument = PDFDocument()

        for pdfData in pdfs {
            if let page = PDFDocument(data: pdfData)?.page(at: 0) {
                pdfDocument.insert(page, at: pdfDocument.pageCount)
            }
        }

        return pdfDocument.dataRepresentation() ?? Data()
    }
}
