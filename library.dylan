Module: dylan-user

define library paths
  use common-dylan;
  use strings;
end;

define module paths
  use common-dylan;
  use strings;
  export
    <path>,
      path-drive,
      path-directory,
      path-basename,
      path-extension,
      path-relative?,
      path-absolute?,
      split-path,               // => dirname, basename, drive
      split-extension,          // => base, extension
      join-paths,
      make-absolute,
      make-relative,
      normalize-path,
      common-prefix,  // could go in strings?
      expand-usernames,
      expand-variables;
      // Also: as(<string>, path)
end module paths;
