import AppKit
import SQLite

func setDesktopImage(screen: NSScreen, imgPath: String, scale: String?) {

  let imgurl = NSURL.fileURL(withPath: imgPath)
  let workspace = NSWorkspace.shared

  var options: [NSWorkspace.DesktopImageOptionKey: Any] = [:]

  if scale == "fill" {
    options[NSWorkspace.DesktopImageOptionKey.imageScaling] = 3 // enum case scaleProportionallyUpOrDown = 3
    options[NSWorkspace.DesktopImageOptionKey.allowClipping] = true
  }

  if scale == "fit" {
    options[NSWorkspace.DesktopImageOptionKey.imageScaling] = 3 // enum case scaleProportionallyUpOrDown = 3
    options[NSWorkspace.DesktopImageOptionKey.allowClipping] = false
  }

  if scale == "stretch" {
    options[NSWorkspace.DesktopImageOptionKey.imageScaling] = 1 // enum case scaleAxesIndependently = 1
    options[NSWorkspace.DesktopImageOptionKey.allowClipping] = true
  }

  if scale == "center" {
    options[NSWorkspace.DesktopImageOptionKey.imageScaling] = 2 // enum case scaleNone = 2
    options[NSWorkspace.DesktopImageOptionKey.allowClipping] = false
  }

  do {
    try workspace.setDesktopImageURL(imgurl, for: screen, options: options)
  } catch {
    print("Error setting wallpaper:", error)
  }
}

func getDesktopImage() -> String {
  let workspace = NSWorkspace.shared
  let screen = NSScreen.main
  let path = workspace.desktopImageURL(for: screen!)!.path
  var isDir: ObjCBool = false

  FileManager.default.fileExists(atPath: path, isDirectory: &isDir)

  if isDir.boolValue {
    let dirs = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.applicationSupportDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
    let dbPath = NSString.path(withComponents: [dirs[0], "Dock/desktoppicture.db"])

    do {
      let table = Table("data")
      let column = Expression<String>("value")
      let rowid = Expression<Int64>("rowid")

      let db = try Connection(dbPath)
      let maxID = try db.scalar(table.select(rowid.max))
      let query = table.select(column).filter(rowid == maxID!) // SELECT * FROM data WHERE rowid=(SELECT max(rowid) FROM data);
      let img = try db.pluck(query)!.get(column)

      return NSString.path(withComponents: [path, img])
    } catch {
      print("Error retrieving image:", error)
    }
  }

  return path
}
