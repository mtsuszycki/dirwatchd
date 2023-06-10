# dirwatchd
Linux directory watching daemon (inotify based) for monitoring files created or deleted from specific directories and taking immediate actions (calling external script) for those event

The main idea behind this was to have a fs event driven system that can react immediately to the filesystem events
(creating or deleting a file) for specific diredtories.

One of the example scenarios is having a server that acts like a content processing centre for media files (audio and video)
dropped to specific directories by different content providers (or other various part of the global system that act on 
behalf of content providers, e.g media company or movie studio).
