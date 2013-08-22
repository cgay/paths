Module: paths
Author: Carl Gay

// First pass will assume posix.  Eventually has to be separated into
// different back-ends for Windows etc.

// Paths are expected to be ephemeral.  Rather than parsing the entire
// thing and storing parts of the path in class slots we just do
// string operations when parts are requested.

// All functions are defined such that if a <path> is passed in,
// <path>s are returned, and if a <string> is passed in, <string>s are
// returned.


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
end method make;

define inline method as
    (class :: subclass(<string>), path :: <path>) => (pathname :: <string>)
  path.%string
end method as;

define sealed class <posix-path> (<path>)
end;

define method path-drive
    (path :: <posix-path>) => (drive == #f)
  #f
end method path-drive;

define method path-directory
    (path :: <posix-path>) => (directory :: <string>)
  split-path(path)  // just use 1st return value
end method path-directory;

define method path-directory
    (path :: <string>) => (directory :: <string>)
  split-path(path)  // just use 1st return value
end method path-directory;

define method path-basename
    (path :: <posix-path>) => (basename :: <string>)
  let (_, basename) = split-path(path);
  basename
end method path-basename;

define method path-basename
    (path :: <string>) => (basename :: <string>)
  let (_, basename) = split-path(path);
  basename
end method path-basename;

define method split-path
    (path :: <posix-path>) => (directory :: <string>, basename :: <path>)
  let (dir, base) = split-path(path.%string);
  values(make(<posix-path>, string: dir),
         make(<posix-path>, string: base))
end method split-path;

define method split-path
    (path :: <string>) => (directory :: <string>, basename :: <path>)
  let sep = rfind(path, '/');
  case
    sep = 0 => values(path, copy-sequence(path, start: 1));
    sep => apply(values, split(path, '/', count: 2, start: sep));
    otherwise => values("", path);
  end
end method split-path;

define method path-extension
    (path :: <posix-path>) => (extension :: <string>)
  path-extension(path.%string)
end method path-extension;

define method path-extension
    (path :: <string>) => (extension :: <string>)
  let dir = rfind(path, '/') | -1;
  let ext = rfind(path, '.') | -1;
  if (ext > dir)
    copy-sequence(path, start: ext + 1)
  else
    ""
  end
end method path-extension;

define method path-absolute?
    (path :: <posix-path>) => (absolute? :: <boolean>)
  path-absolute?(path.%string)
end method path-absolute?;

define method path-absolute?
    (path :: <string>) => (absolute? :: <boolean>)
  starts-with?(path, "/")
end method path-absolute?;

define method path-relative?
    (path :: <posix-path>) => (relative? :: <boolean>)
  ~path-absolute?(path)
end method path-relative?;

define method path-relative?
    (path :: <string>) => (relative? :: <boolean>)
  ~path-absolute?(path)
end method path-relative?;

define method normalize-path
    (path :: <path>) => (normpath :: <path>)
  make(<posix-path>, string: normalize-path(path.%string))
end method normalize-path;

define method normalize-path
    (path :: <string>) => (normpath :: <string>)
  if (path.empty?)
    ""
  else
    let initial-slashes = starts-with?(path, "/") & 1;
    if (initial-slashes & starts-with?(path, "//") & ~starts-with?(path, "///"))
      initial-slashes := 2;
    end;
    iterate loop (comps = split(path, '/'), new = #())
      if (comps.empty?)
        let newpath = join(reverse!(new), "/");
        if (initial-slashes = 2)
          concatenate("//", newpath)
        elseif (initial-slashes)
          concatenate("/", newpath)
        elseif (newpath.empty?)
          "."
        else
          newpath
        end
      else
        let comp = comps[0];
        if (comp = "" | comp = ".")
          loop(comps.tail, new)
        elseif (comp ~= ".."
                  | (~initial-slashes & new.empty?)
                  | (~new.empty? & new.head = ".."))
          loop(comps.tail, pair(comp, new))
        elseif (~new.empty?)
          loop(comps.tail, new.tail)
        else
          loop(comps.tail, new)
        end if
      end if
    end iterate
  end if
end method normalize-path;

//// Utilities/helpers

define function rfind
    (big :: <string>, char :: <character>) => (index :: false-or(<integer>))
  iterate loop (i = big.size - 1)
    case
      i < 0 => #f;
      big[i] = char => i;
      otherwise => loop(i - 1);
    end
  end
end function rfind;
