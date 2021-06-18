import os
import strutils

var APPNAME: string

proc getStorageDir*(): string =
    return getStorageDir() / APPNAME

proc getFullFilePath*(file: string): string =
    if not file.contains("://"):
        echo "BAD PATH: file"
        quit(1)
    case file.split("://")[0]:
    of "cont", "content":
        return getAppDir() / "content" / file.split("://")[1]
    of "res", "resources":
        return getStorageDir() / file.split("://")[1]