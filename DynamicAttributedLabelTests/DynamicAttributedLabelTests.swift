import XCTest
@testable import DynamicAttributedLabel

class CustomVC: UIViewController {
  override func viewIsAppearing(_ animated: Bool) {
    super.viewIsAppearing(animated)

    NotificationCenter.default.post(name: UIContentSizeCategory.didChangeNotification, object: nil)

  }
}

final class DynamicAttributedLabelTests: XCTestCase {

  func test() {
    let vc = CustomVC()
    vc.view.backgroundColor = .white

    let label = AttributedLabel(text: "TEXT", sendTraits: true)
    label.backgroundColor = .green

    vc.view.addSubview(label)

    NSLayoutConstraint.activate([
      label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
      label.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
    ])

    record(
      snapshot: vc.snapshot(for: .iPhone14(style: .light, contentSize: .extraExtraExtraLarge)),
      named: "AttributedLabel"
    )
  }
}

extension XCTestCase {

  func assert(snapshot: UIImage, named name: String, file: StaticString = #filePath, line: UInt = #line) {
    let snapshotData = makeSnapshotData(from: snapshot)
    let snapshotURL = makeSnapshotURL(named: name)

    guard let storedSnapshotData = try? Data(contentsOf: snapshotURL) else {
      XCTFail(
        "Failed to load snapshot from url: \(snapshotURL). Use `record` method to store a snapshot before asserting",
        file: file,
        line: line
      )
      return
    }

    if snapshotData != storedSnapshotData {
      let temporarySnapshotURL = URL(filePath: NSTemporaryDirectory())
        .appending(component: snapshotURL.lastPathComponent)
      try? snapshotData?.write(to: temporarySnapshotURL)

      XCTFail(
        "New snapshot does not match stored snapshot. New snapshot URL: \(temporarySnapshotURL). Stored snapshot URL: \(snapshotURL)",
        file: file,
        line: line
      )
    }
  }

  func record(snapshot: UIImage, named name: String, file: StaticString = #filePath, line: UInt = #line) {
    let snapshotData = makeSnapshotData(from: snapshot)
    let snapshotURL = makeSnapshotURL(named: name)

    do {
      try FileManager.default.createDirectory(
        at: snapshotURL.deletingLastPathComponent(),
        withIntermediateDirectories: true
      )
      try snapshotData?.write(to: snapshotURL)
      XCTFail("Record succeeded — change to 'assert' to compare the snapshots from now on.", file: file, line: line)
    } catch {
      XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
    }
  }

  private func makeSnapshotURL(named name: String, file: StaticString = #file) -> URL {
    let snapshotURL = URL(filePath: String(describing: file))
      .deletingLastPathComponent()
      .appending(component: "snapshots")
      .appending(component: "\(name).png")
    return snapshotURL
  }

  private func makeSnapshotData(from snapshot: UIImage,  file: StaticString = #file, line: UInt = #line) -> Data? {
    guard let snapshotData = snapshot.pngData() else {
      XCTFail("Failed to generate PNG data from a snapshot", file: file, line: line)
      return nil
    }
    return snapshotData
  }
}

extension UIViewController {
  func snapshot(for configuration: SnapshotConfiguration) -> UIImage {
    SnapshotWindow(configuration: configuration, root: self).snapshot()
  }
}

struct SnapshotConfiguration {
  let size: CGSize
  let safeAreaInsets: UIEdgeInsets
  let layoutMargins: UIEdgeInsets
  let traitCollection: UITraitCollection

  static func iPhone14(style: UIUserInterfaceStyle, contentSize: UIContentSizeCategory = .medium) -> SnapshotConfiguration {
    return SnapshotConfiguration(
      size: CGSize(width: 390, height: 844),
      safeAreaInsets: UIEdgeInsets(top: 47, left: 0, bottom: 34, right: 0),
      layoutMargins: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16),
      traitCollection: UITraitCollection(traitsFrom: [
        .init(forceTouchCapability: .unavailable),
        .init(layoutDirection: .leftToRight),
        .init(preferredContentSizeCategory: contentSize),
        .init(userInterfaceIdiom: .phone),
        .init(horizontalSizeClass: .compact),
        .init(verticalSizeClass: .regular),
        .init(displayScale: 3),
        .init(displayGamut: .P3),
        .init(userInterfaceStyle: style)
      ]))
  }
}

private final class SnapshotWindow: UIWindow {
  private var configuration: SnapshotConfiguration = .iPhone14(style: .light)

  convenience init(configuration: SnapshotConfiguration, root: UIViewController) {
    self.init(frame: CGRect(origin: .zero, size: configuration.size))
    self.configuration = configuration
    self.layoutMargins = configuration.layoutMargins
    self.rootViewController = root
    self.isHidden = false
    root.view.layoutMargins = configuration.layoutMargins
  }

  override var safeAreaInsets: UIEdgeInsets {
    return configuration.safeAreaInsets
  }

  override var traitCollection: UITraitCollection {
    return UITraitCollection(traitsFrom: [super.traitCollection, configuration.traitCollection])
  }

  func snapshot() -> UIImage {
    let renderer = UIGraphicsImageRenderer(bounds: bounds, format: .init(for: traitCollection))
    return renderer.image { context in
      layer.render(in: context.cgContext)
    }
  }
}
