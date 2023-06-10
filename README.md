# dirwatchd
Linux directory watching daemon (inotify based) for monitoring files created or deleted from specific directories and taking immediate actions (calling external script) for those events

The main idea behind this was to have a fs event driven system that can react immediately to the filesystem events
(creating or deleting a file) for specific directories.

One of the example scenarios is having a server that acts like a content processing centre for media files (audio and video)
dropped to specific directories by different content providers (or other various part of the global system that act on 
behalf of content providers, e.g media company or movie studio).
Dirwatchd uses Linux inotify syscall which guarantees almost immediate reaction and it was meant to remove
any delay from content processing pipeline - as soon as the file is dropped to a watched directory then
the appropriate script is called for that file, and can take any desired action (file conversion, moving to different place,
sending email etc.)

```
USAGE:
copy dirwatchd.conf to /etc
copy dirwatch-lib.sh and dirwatch-*.sh to /usr/libexec/dirwatch/

Copy dirwatchd.init to your /etc/ init directory

Edit dirwatchd.conf and run dirwatchd

```
dirwatchd.conf is pretty self explanatory
External scripts can be called with a combination of following abbreviations:
```
# %n - name of the file created/deleted
# %e - event name: "event_delete" or "event_create"
# %p - path that will be watched, as specified in config file
# %d - actual, full directory path where the event occured (that is, where %n was created/deleted)
# %d and %p have extra feature: e.g %d[4] is THE FIFTH ELEMENT (I love this movie) (of the path)

```

dirwatch-lib.sh is an example file with some helper functions, like computing the duration
of a video file etc. These are just examples and the tools like ReadMPEG are not provided.
