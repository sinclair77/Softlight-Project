import Cocoa
#if canImport(FlutterMacOS)
import FlutterMacOS
#else
/// Minimal stand-ins so SourceKit can lint without FlutterMacOS.
class FlutterViewController: NSViewController {}
func RegisterGeneratedPlugins(registry _: Any) {}
#endif

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
