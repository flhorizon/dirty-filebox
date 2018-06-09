FileUploadWebapp
=====================

Wirelessly transfering heavy files home on Android has become a major PITA.

Everything is mounted with mode 700 belonging to root.

Bluetooth is slow.

Most dedicated server/client app for FTP/HTTP file transfer try to access filesystem directly and cannot even open files, let alone sometimes search directories.

Quick 'n dirty way without learning Android programming from scratch ? 

Serve a web interface to upload files/

## Elm front.

Because, why not.

Granted, there's overhead for such a simple purpose which only demands a few JS lines.

Still demands ports in Elm. BTW

## Backend

A backend should serve static files and have a route to store uploaded files.

The backend will store provided files in CWD.

## Reference

This work will be based on 

https://www.paramander.com/blog/using-ports-to-deal-with-files-in-elm-0-17
