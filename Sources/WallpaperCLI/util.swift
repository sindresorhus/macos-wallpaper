import Foundation

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
