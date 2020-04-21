import Cocoa


extension FileHandle: TextOutputStream {
	public func write(_ string: String) {
		write(string.data(using: .utf8)!)
	}
}


private struct CLI {
	static var standardInput = FileHandle.standardInput
	static var standardOutput = FileHandle.standardOutput
	static var standardError = FileHandle.standardError
}

enum PrintOutputTarget {
	case standardOutput
	case standardError
}

/// Make `print()` accept an array of items.
/// Since Swift doesn't support spreading...
private func print<Target>(
	_ items: [Any],
	separator: String = " ",
	terminator: String = "\n",
	to output: inout Target
) where Target: TextOutputStream {
	let item = items.map { "\($0)" }.joined(separator: separator)
	Swift.print(item, terminator: terminator, to: &output)
}

func print(
	_ items: Any...,
	separator: String = " ",
	terminator: String = "\n",
	to output: PrintOutputTarget = .standardOutput
) {
	switch output {
	case .standardOutput:
		print(items, separator: separator, terminator: terminator)
	case .standardError:
		print(items, separator: separator, terminator: terminator, to: &CLI.standardError)
	}
}


extension NSColor {
	/**
	```
	NSColor(hex: 0xFFFFFF)
	```
	*/
	convenience init(hex: Int, alpha: Double = 1) {
		self.init(
			red: CGFloat((hex >> 16) & 0xFF) / 255,
			green: CGFloat((hex >> 8) & 0xFF) / 255,
			blue: CGFloat(hex & 0xFF) / 255,
			alpha: CGFloat(alpha)
		)
	}

	convenience init?(hexString: String, alpha: Double = 1) {
		var string = hexString

		if hexString.hasPrefix("#") {
			string = String(hexString.dropFirst())
		}

		if string.count == 3 {
			string = string.map { "\($0)\($0)" }.joined()
		}

		guard let hex = Int(string, radix: 16) else {
			return nil
		}

		self.init(hex: hex, alpha: alpha)
	}
}
