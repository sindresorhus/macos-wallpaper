import AppKit

extension Collection {
	/// Access a collection by index safely
	public subscript(safe index: Index) -> Element? {
		return indices.contains(index) ? self[index] : nil
	}
}

extension URL {
	private func resourceValue<T>(forKey key: URLResourceKey) -> T? {
		guard let values = try? resourceValues(forKeys: [key]) else {
			return nil
		}

		return values.allValues[key] as? T
	}

	private func boolResourceValue(forKey key: URLResourceKey, defaultValue: Bool = false) -> Bool {
		guard let values = try? resourceValues(forKeys: [key]) else {
			return defaultValue
		}

		return values.allValues[key] as? Bool ?? defaultValue
	}

	// TODO: This should not be public, but Swift complains if it's not
	public var isDirectory: Bool {
		return boolResourceValue(forKey: .isDirectoryKey)
	}
}
