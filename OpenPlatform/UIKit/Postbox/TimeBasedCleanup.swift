import Foundation

private typealias SignalKitTimer = Timer

struct InodeInfo {
    var inode: __darwin_ino64_t
    var timestamp: Int32
    var size: UInt32
}

private struct ScanFilesResult {
    var unlinkedCount = 0
    var totalSize: UInt64 = 0
}

internal func printOpenFiles() {
    var flags: Int32 = 0
    var fd: Int32 = 0
    var buf = Data(count: Int(MAXPATHLEN) + 1)
    let maxFd = min(1024, FD_SETSIZE)
    
    while fd < maxFd {
        errno = 0;
        flags = fcntl(fd, F_GETFD, 0);
        if flags == -1 && errno != 0 {
            if errno != EBADF {
                return
            } else {
                continue
            }
        }
        
        buf.withUnsafeMutableBytes { buffer -> Void in
            let _ = fcntl(fd, F_GETPATH, buffer.baseAddress!)
            let string = String(cString: buffer.baseAddress!.assumingMemoryBound(to: CChar.self))
            postboxLog("f: \(string)")
        }
        
        fd += 1
    }
}
