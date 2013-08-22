Module: paths
Author: Carl Gay

// First pass will assume posix.  Eventually has to be separated into
// different back-ends for Windows etc.

// Paths are expected to be ephemeral.  Rather than parsing the entire
// thing and storing parts of the path in class slots we just do
// string operations when parts are requested.

define constant $drive-separator :: <character> = ':';
define constant $directory-separator :: <character> = '/';
define constant $extension-separator :: <character> = '.';
define constant $current-directory :: <string> = ".";
define constant $parent-directory :: <string> = "..";

define class <path-error> (<simple-condition>, <error>)
end;

define sealed class <path> (<object>)
  constant slot %string :: <string>,
    required-init-keyword: string:;
end;

define method make
    (class :: subclass(<path>), #key string :: <string>)
 => (path :: <path>)
  if (string.size = 0)
    signal(make(<path-error>,
                format-string: "An empty string is not a valid <path>."));
  else
    next-method()
  end
end;

define inline method as
    (class :: subclass(<string>), path :: <path>) => (pathname :: <string>)
  path.%string
end;

define sealed class <posix-path> (<path>)
end;

define method path-drive
    (path :: <posix-path>) => (drive == #f)
  #f  // posix
end;

define method path-directory
    (path :: <posix-path>) => (directory :: <string>)
  split-path(path)  // just use 1st return value
end;

define method path-basename
    (path :: <posix-path>) => (basename :: <string>)
  make-path(path-basename(path.%string))
end;

define method path-basename
    (path :: <string>) => (basename :: <string>)
  let (_, basename) = split-path(path);
  basename
end;

define method split-path
    (path :: <posix-path>) => (directory :: <string>, basename :: <path>)
  let (dir, base) = split-path(path.%string);
  values(make-path(dir), make-path(base))
end;

define method split-path
    (path :: <string>) => (directory :: <string>, basename :: <path>)
  let sep = rfind(path, $directory-separator);
  case
    sep = 0 => values(path, copy-sequence(path, start: 1));
    sep => apply(values, split(path, $directory-separator, count: 2, start: sep));
    otherwise => values("", path);
  end
end;

// Hmmm.  Many of these methods should return paths, perhaps with
// internal versions that return strings.

define method path-extension
    (path :: <posix-path>) => (directory :: <string>)
  let %path = path.%string;
  let dir = rfind(%path, $directory-separator) | -1;
  let ext = rfind(%path, $extension-separator) | -1;
  if (ext > dir)
    copy-sequence(%path, start: ext)
  else
    ""
  end
end;

define method path-absolute?
    (path :: <posix-path>) => (relative? :: <boolean>)
  let %path = path.%string;
  starts-with(%path, $directory-separator)
end;

define method path-relative?
    (path :: <posix-path>) => (absolute? :: <boolean>)
  ~path-absolute?(path)
end;
