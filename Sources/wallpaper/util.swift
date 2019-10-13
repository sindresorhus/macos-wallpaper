import AppKit

func sleep(for duration: TimeInterval) {
	usleep(useconds_t(duration * Double(USEC_PER_SEC)))
}

extension Collection {
	/// Access a collection by index safely.
	subscript(safe index: Index) -> Element? {
		indices.contains(index) ? self[index] : nil
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

	var isDirectory: Bool { boolResourceValue(forKey: .isDirectoryKey) }
}

extension NSScreen {
	private func infoForCGDisplay(_ displayID: CGDirectDisplayID, options: Int) -> [AnyHashable: Any]? {
		var iterator: io_iterator_t = 0

		let result = IOServiceGetMatchingServices(kIOMasterPortDefault, IOServiceMatching("IODisplayConnect"), &iterator)
		guard result == kIOReturnSuccess else {
			print("Could not find services for IODisplayConnect: \(result)")
			return nil
		}

		var service = IOIteratorNext(iterator)
		while service != 0 {
			let info = IODisplayCreateInfoDictionary(service, IOOptionBits(options)).takeRetainedValue() as! [AnyHashable: Any]

			guard
				let vendorID = info[kDisplayVendorID] as! UInt32?,
				let productID = info[kDisplayProductID] as! UInt32?
			else {
				continue
			}

			if vendorID == CGDisplayVendorNumber(displayID) && productID == CGDisplayModelNumber(displayID) {
				return info
			}

			service = IOIteratorNext(iterator)
		}

		return nil
	}

	var id: CGDirectDisplayID {
		deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as! CGDirectDisplayID
	}

	var name: String {
		guard let info = infoForCGDisplay(id, options: kIODisplayOnlyPreferredName) else {
			return "Unknown screen"
		}

		guard
			let localizedNames = info[kDisplayProductName] as? [String: Any],
			let name = localizedNames.values.first as? String
		else {
			return "Unnamed screen"
		}

		return name
	}
}
